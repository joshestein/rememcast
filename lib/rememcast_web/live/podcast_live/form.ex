defmodule RememcastWeb.PodcastLive.Form do
  use RememcastWeb, :live_view

  alias Rememcast.Content
  alias Rememcast.Content.Podcast

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Search for new podcasts.</:subtitle>
      </.header>

      <.form id="search-form" phx-submit="search">
        <div class="flex flex-col gap-2">
          <label class="input input-md">
            <svg class="h-[1em] opacity-50" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
              <g
                stroke-linejoin="round"
                stroke-linecap="round"
                stroke-width="2.5"
                fill="none"
                stroke="currentColor"
              >
                <circle cx="11" cy="11" r="8"></circle>
                <path d="m21 21-4.3-4.3"></path>
              </g>
            </svg>
            <input name="q" type="search" class="grow" placeholder="What are you listening to?" />
          </label>
          <.button phx-disable-with="Searching..." variant="primary">Search</.button>
        </div>
      </.form>

      <div id="search-results" phx-update="stream" class="mt-4">
        <div
          :for={{id, result} <- @streams.search_results}
          class="flex items-center gap-4 p-2 rounded-lg hover:bg-base-200"
          id={id}
        >
          <img src={result.artwork} class="w-12 h-12 rounded-md" />
          <div class="flex-grow">
            <div class="font-bold">{result.title}</div>
            <div class="text-sm opacity-75">{result.author}</div>
          </div>
          <.button phx-click="select_podcast" phx-value-id={result.id} class="btn btn-sm">
            Select
          </.button>
        </div>
      </div>

      <.form for={@form} id="podcast-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:image_url]} type="text" label="Image url" />
        <.input field={@form[:podcast_index_id]} type="number" label="Podcast index" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:author]} type="text" label="Author" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Podcast</.button>
          <.button navigate={return_path(@return_to, @podcast)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> stream(:search_results, [])
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    podcast = Content.get_podcast!(id)

    socket
    |> assign(:page_title, "Edit Podcast")
    |> assign(:podcast, podcast)
    |> assign(:form, to_form(Content.change_podcast(podcast)))
  end

  defp apply_action(socket, :new, _params) do
    podcast = %Podcast{}

    socket
    |> assign(:page_title, "Add Podcast")
    |> assign(:podcast, podcast)
    |> assign(:form, to_form(Content.change_podcast(podcast)))
  end

  @impl true
  def handle_event("validate", %{"podcast" => podcast_params}, socket) do
    changeset = Content.change_podcast(socket.assigns.podcast, podcast_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"podcast" => podcast_params}, socket) do
    save_podcast(socket, socket.assigns.live_action, podcast_params)
  end

  def handle_event("search", %{"q" => query}, socket) do
    case search_podcast(query) do
      {:ok, results} ->
        {:noreply, stream(socket, :search_results, results, reset: true)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Podcast search failed")
         |> stream(:search_results, [], reset: true)}
    end
  end

  defp save_podcast(socket, :edit, podcast_params) do
    case Content.update_podcast(socket.assigns.podcast, podcast_params) do
      {:ok, podcast} ->
        {:noreply,
         socket
         |> put_flash(:info, "Podcast updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, podcast))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_podcast(socket, :new, podcast_params) do
    case Content.create_podcast(podcast_params) do
      {:ok, podcast} ->
        {:noreply,
         socket
         |> put_flash(:info, "Podcast created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, podcast))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp search_podcast(query) do
    api_key = Application.get_env(:rememcast, :podcast_index_api_key)
    secret_key = Application.get_env(:rememcast, :podcast_index_secret_key)
    unix_timestamp = System.os_time(:second)

    sha1_hash =
      :crypto.hash(:sha, "#{api_key}#{secret_key}#{unix_timestamp}")
      |> Base.encode16(case: :lower)

    case Req.get!("https://api.podcastindex.org/api/1.0/search/byterm",
           headers: [
             {"User-Agent", "RememCast/1.0"},
             {"X-Auth-Key", api_key},
             {"X-Auth-Date", unix_timestamp},
             {"Authorization", sha1_hash}
           ],
           params: %{"q" => query}
         ) do
      %{status: 200, body: body} ->
        results = parse_results(body)
        {:ok, results}

      %{status: status} ->
        {:error, "Podcast Index API returned status #{status}"}
    end
  end

  defp parse_results(%{"feeds" => feeds}) do
    Enum.map(feeds, fn feed ->
      %{
        id: feed["id"],
        title: feed["title"],
        description: feed["description"],
        author: feed["author"],
        artwork: feed["artwork"]
      }
    end)
  end

  defp return_path("index", _podcast), do: ~p"/podcasts"
  defp return_path("show", podcast), do: ~p"/podcasts/#{podcast}"
end

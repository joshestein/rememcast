defmodule RememcastWeb.EpisodeLive.Form do
  use RememcastWeb, :live_view

  alias Rememcast.Content
  alias Rememcast.Content.Episode

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Search for new episodes.</:subtitle>
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

      <div id="podcast-results" phx-update="stream" class="mt-4">
        <div
          :for={{id, podcast} <- @streams.podcasts}
          class="flex items-center gap-4 p-2 rounded-lg hover:bg-base-200"
          id={id}
        >
          <img src={podcast.artwork} class="w-12 h-12 rounded-md" />
          <div class="flex-grow">
            <div class="font-bold">{podcast.title}</div>
            <div class="text-sm opacity-75">{podcast.author}</div>
          </div>
          <.button phx-click="select_podcast" phx-value-id={podcast.id} class="btn btn-sm">
            Select
          </.button>
        </div>
      </div>

      <.form for={@form} id="episode-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:publish_date]} type="datetime-local" label="Publish date" />
        <.input field={@form[:duration]} type="number" label="Duration" />
        <.input field={@form[:audio_url]} type="text" label="Audio url" />
        <.input field={@form[:guid]} type="text" label="Guid" />
        <.input field={@form[:episode_number]} type="number" label="Episode index" />
        <.input field={@form[:image]} type="text" label="Image" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Episode</.button>
          <.button navigate={return_path(@return_to, @episode)}>Cancel</.button>
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
     |> stream(:podcasts, [])
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    episode = Content.get_episode!(id)

    socket
    |> assign(:page_title, "Edit Episode")
    |> assign(:episode, episode)
    |> assign(:form, to_form(Content.change_episode(episode)))
  end

  defp apply_action(socket, :new, _params) do
    episode = %Episode{}

    socket
    |> assign(:page_title, "Add Episode")
    |> assign(:episode, episode)
    |> assign(:form, to_form(Content.change_episode(episode)))
  end

  @impl true
  def handle_event("validate", %{"episode" => episode_params}, socket) do
    changeset = Content.change_episode(socket.assigns.episode, episode_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"episode" => episode_params}, socket) do
    save_episode(socket, socket.assigns.live_action, episode_params)
  end

  def handle_event("search", %{"q" => query}, socket) do
    case search_podcast(query) do
      {:ok, podcasts} ->
        podcast_map = Map.new(podcasts, fn result -> {result.id, result} end)

        {:noreply,
         socket
         |> stream(:podcasts, podcasts, reset: true)
         |> assign(:podcast_map, podcast_map)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Podcast search failed")
         |> stream(:podcasts, [], reset: true)
         |> assign(:podcast_map, %{})}
    end
  end

  def handle_event("select_podcast", %{"id" => id}, socket) do
    selected_podcast = String.to_integer(id)

    case Map.get(socket.assigns.podcast_map, selected_podcast) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Selected podcast not found")}

      selected_podcast ->
        episodes = search_podcast_episode(selected_podcast.id)

        Logger.info(
          "Selected podcast: #{inspect(selected_podcast)} with episodes: #{inspect(episodes)}"
        )

        {:noreply, socket}
    end
  end

  defp save_episode(socket, :edit, episode_params) do
    case Content.update_episode(socket.assigns.episode, episode_params) do
      {:ok, episode} ->
        {:noreply,
         socket
         |> put_flash(:info, "Episode updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, episode))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_episode(socket, :new, episode_params) do
    case Content.create_episode(episode_params) do
      {:ok, episode} ->
        {:noreply,
         socket
         |> put_flash(:info, "Episode created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, episode))}

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
        results = parse_podcast_results(body)
        {:ok, results}

      %{status: status} ->
        {:error, "Podcast Index API returned status #{status}"}
    end
  end

  defp parse_podcast_results(%{"feeds" => feeds}) do
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

  defp search_podcast_episode(feed_id) do
    api_key = Application.get_env(:rememcast, :podcast_index_api_key)
    secret_key = Application.get_env(:rememcast, :podcast_index_secret_key)
    unix_timestamp = System.os_time(:second)

    sha1_hash =
      :crypto.hash(:sha, "#{api_key}#{secret_key}#{unix_timestamp}")
      |> Base.encode16(case: :lower)

    case Req.get!("https://api.podcastindex.org/api/1.0/episodes/byfeedid",
           headers: [
             {"User-Agent", "RememCast/1.0"},
             {"X-Auth-Key", api_key},
             {"X-Auth-Date", unix_timestamp},
             {"Authorization", sha1_hash}
           ],
           params: %{"id" => feed_id, "max" => 10}
         ) do
      %{status: 200, body: body} ->
        results = parse_podcast_episode_results(body)
        {:ok, results}

      %{status: status} ->
        {:error, "Podcast Index API returned status #{status}"}
    end
  end

  defp parse_podcast_episode_results(%{"items" => items}) do
    Enum.map(items, fn item ->
      %{
        id: item["id"],
        title: item["title"],
        description: item["description"],
        publish_date: item["datePublished"],
        duration: item["duration"],
        audio_url: item["enclosureUrl"],
        guid: item["guid"],
        episode_number: item["episode"],
        image: item["image"]
      }
    end)
  end

  defp return_path("index", _episode), do: ~p"/episodes"
  defp return_path("show", episode), do: ~p"/episodes/#{episode}"
end

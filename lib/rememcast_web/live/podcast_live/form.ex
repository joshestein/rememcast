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
        <:subtitle>Use this form to manage podcast records in your database.</:subtitle>
      </.header>

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
    |> assign(:page_title, "New Podcast")
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

  defp return_path("index", _podcast), do: ~p"/podcasts"
  defp return_path("show", podcast), do: ~p"/podcasts/#{podcast}"
end

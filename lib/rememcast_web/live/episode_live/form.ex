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
        <:subtitle>Use this form to manage episode records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="episode-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:publish_date]} type="datetime-local" label="Publish date" />
        <.input field={@form[:duration]} type="number" label="Duration" />
        <.input field={@form[:audio_url]} type="text" label="Audio url" />
        <.input field={@form[:guid]} type="text" label="Guid" />
        <.input field={@form[:episode_index_id]} type="number" label="Episode index" />
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
    |> assign(:page_title, "New Episode")
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

  defp return_path("index", _episode), do: ~p"/episodes"
  defp return_path("show", episode), do: ~p"/episodes/#{episode}"
end

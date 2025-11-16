defmodule RememcastWeb.EpisodeLive.Index do
  use RememcastWeb, :live_view

  alias Rememcast.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Episodes
        <:actions>
          <.button variant="primary" navigate={~p"/episodes/new"}>
            <.icon name="hero-plus" /> New Episode
          </.button>
        </:actions>
      </.header>

      <.table
        id="episodes"
        rows={@streams.episodes}
        row_click={fn {_id, episode} -> JS.navigate(~p"/episodes/#{episode}") end}
      >
        <:col :let={{_id, episode}} label="Title">{episode.title}</:col>
        <:col :let={{_id, episode}} label="Description">{episode.description}</:col>
        <:col :let={{_id, episode}} label="Publish date">{episode.publish_date}</:col>
        <:col :let={{_id, episode}} label="Duration">{episode.duration}</:col>
        <:col :let={{_id, episode}} label="Audio url">{episode.audio_url}</:col>
        <:col :let={{_id, episode}} label="Guid">{episode.guid}</:col>
        <:col :let={{_id, episode}} label="Episode number">{episode.episode_number}</:col>
        <:action :let={{_id, episode}}>
          <div class="sr-only">
            <.link navigate={~p"/episodes/#{episode}"}>Show</.link>
          </div>
          <.link navigate={~p"/episodes/#{episode}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, episode}}>
          <.link
            phx-click={JS.push("delete", value: %{id: episode.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Episodes")
     |> stream(:episodes, list_episodes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    episode = Content.get_episode!(id)
    {:ok, _} = Content.delete_episode(episode)

    {:noreply, stream_delete(socket, :episodes, episode)}
  end

  defp list_episodes() do
    Content.list_episodes()
  end
end

defmodule RememcastWeb.PodcastLive.Index do
  use RememcastWeb, :live_view

  alias Rememcast.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Podcasts
        <:actions>
          <.button variant="primary" navigate={~p"/podcasts/new"}>
            <.icon name="hero-plus" /> New Podcast
          </.button>
        </:actions>
      </.header>

      <.table
        id="podcasts"
        rows={@streams.podcasts}
        row_click={fn {_id, podcast} -> JS.navigate(~p"/podcasts/#{podcast}") end}
      >
        <:col :let={{_id, podcast}} label="Title">{podcast.title}</:col>
        <:col :let={{_id, podcast}} label="Description">{podcast.description}</:col>
        <:col :let={{_id, podcast}} label="Author">{podcast.author}</:col>
        <:action :let={{_id, podcast}}>
          <div class="sr-only">
            <.link navigate={~p"/podcasts/#{podcast}"}>Show</.link>
          </div>
          <.link navigate={~p"/podcasts/#{podcast}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, podcast}}>
          <.link
            phx-click={JS.push("delete", value: %{id: podcast.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Podcasts")
     |> stream(:podcasts, list_podcasts())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    podcast = Content.get_podcast!(id)
    {:ok, _} = Content.delete_podcast(podcast)

    {:noreply, stream_delete(socket, :podcasts, podcast)}
  end

  defp list_podcasts() do
    Content.list_podcasts()
  end
end

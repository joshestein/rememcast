defmodule RememcastWeb.PodcastLive.Show do
  use RememcastWeb, :live_view

  alias Rememcast.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Podcast {@podcast.id}
        <:subtitle>This is a podcast record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/podcasts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/podcasts/#{@podcast}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit podcast
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@podcast.title}</:item>
        <:item title="Artwork">{@podcast.artwork}</:item>
        <:item title="Podcast index">{@podcast.podcast_index_id}</:item>
        <:item title="Description">{@podcast.description}</:item>
        <:item title="Url">{@podcast.url}</:item>
        <:item title="Author">{@podcast.author}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Podcast")
     |> assign(:podcast, Content.get_podcast!(id))}
  end
end

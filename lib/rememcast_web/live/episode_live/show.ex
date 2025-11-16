defmodule RememcastWeb.EpisodeLive.Show do
  use RememcastWeb, :live_view

  alias Rememcast.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Episode {@episode.id}
        <:subtitle>This is a episode record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/episodes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/episodes/#{@episode}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit episode
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@episode.title}</:item>
        <:item title="Description">{@episode.description}</:item>
        <:item title="Publish date">{@episode.publish_date}</:item>
        <:item title="Duration">{@episode.duration}</:item>
        <:item title="Audio url">{@episode.audio_url}</:item>
        <:item title="Guid">{@episode.guid}</:item>
        <:item title="Image">{@episode.image}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Episode")
     |> assign(:episode, Content.get_episode!(id))}
  end
end

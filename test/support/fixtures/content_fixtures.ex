defmodule Rememcast.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rememcast.Content` context.
  """

  @doc """
  Generate a podcast.
  """
  def podcast_fixture(attrs \\ %{}) do
    {:ok, podcast} =
      attrs
      |> Enum.into(%{
        author: "some author",
        description: "some description",
        artwork: "some artwork",
        guid: "some guid",
        title: "some title",
        url: "some url"
      })
      |> Rememcast.Content.create_podcast()

    podcast
  end

  @doc """
  Generate a episode.
  """
  def episode_fixture(attrs \\ %{}) do
    {:ok, episode} =
      attrs
      |> Enum.into(%{
        audio_url: "some audio_url",
        description: "some description",
        duration: 42,
        guid: "some guid",
        image: "some image",
        publish_date: ~U[2025-11-15 16:43:00Z],
        title: "some title",
        podcast_id: podcast_fixture().id
      })
      |> Rememcast.Content.create_episode()

    episode
  end
end

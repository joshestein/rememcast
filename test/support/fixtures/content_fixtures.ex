defmodule Rememcast.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rememcast.Content` context.
  """

  @doc """
  Generate a unique podcast podcast_index_id.
  """
  def unique_podcast_podcast_index_id, do: System.unique_integer([:positive])

  @doc """
  Generate a podcast.
  """
  def podcast_fixture(attrs \\ %{}) do
    {:ok, podcast} =
      attrs
      |> Enum.into(%{
        author: "some author",
        description: "some description",
        image_url: "some image_url",
        podcast_index_id: unique_podcast_podcast_index_id(),
        title: "some title",
        url: "some url"
      })
      |> Rememcast.Content.create_podcast()

    podcast
  end
end

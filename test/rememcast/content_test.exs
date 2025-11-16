defmodule Rememcast.ContentTest do
  use Rememcast.DataCase

  alias Rememcast.Content

  describe "podcasts" do
    alias Rememcast.Content.Podcast

    import Rememcast.ContentFixtures

    @invalid_attrs %{
      description: nil,
      author: nil,
      title: nil,
      url: nil,
      artwork: nil,
      podcast_index_id: nil
    }

    test "list_podcasts/0 returns all podcasts" do
      podcast = podcast_fixture()
      assert Content.list_podcasts() == [podcast]
    end

    test "get_podcast!/1 returns the podcast with given id" do
      podcast = podcast_fixture()
      assert Content.get_podcast!(podcast.id) == podcast
    end

    test "create_podcast/1 with valid data creates a podcast" do
      valid_attrs = %{
        description: "some description",
        author: "some author",
        title: "some title",
        url: "some url",
        artwork: "some artwork",
        podcast_index_id: 42
      }

      assert {:ok, %Podcast{} = podcast} = Content.create_podcast(valid_attrs)
      assert podcast.description == "some description"
      assert podcast.author == "some author"
      assert podcast.title == "some title"
      assert podcast.url == "some url"
      assert podcast.artwork == "some artwork"
      assert podcast.podcast_index_id == 42
    end

    test "create_podcast/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_podcast(@invalid_attrs)
    end

    test "update_podcast/2 with valid data updates the podcast" do
      podcast = podcast_fixture()

      update_attrs = %{
        description: "some updated description",
        author: "some updated author",
        title: "some updated title",
        url: "some updated url",
        artwork: "some updated artwork",
        podcast_index_id: 43
      }

      assert {:ok, %Podcast{} = podcast} = Content.update_podcast(podcast, update_attrs)
      assert podcast.description == "some updated description"
      assert podcast.author == "some updated author"
      assert podcast.title == "some updated title"
      assert podcast.url == "some updated url"
      assert podcast.artwork == "some updated artwork"
      assert podcast.podcast_index_id == 43
    end

    test "update_podcast/2 with invalid data returns error changeset" do
      podcast = podcast_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_podcast(podcast, @invalid_attrs)
      assert podcast == Content.get_podcast!(podcast.id)
    end

    test "delete_podcast/1 deletes the podcast" do
      podcast = podcast_fixture()
      assert {:ok, %Podcast{}} = Content.delete_podcast(podcast)
      assert_raise Ecto.NoResultsError, fn -> Content.get_podcast!(podcast.id) end
    end

    test "change_podcast/1 returns a podcast changeset" do
      podcast = podcast_fixture()
      assert %Ecto.Changeset{} = Content.change_podcast(podcast)
    end
  end
end

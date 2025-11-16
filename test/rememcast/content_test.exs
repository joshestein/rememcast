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
      guid: nil
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
        guid: "some guid"
      }

      assert {:ok, %Podcast{} = podcast} = Content.create_podcast(valid_attrs)
      assert podcast.description == "some description"
      assert podcast.author == "some author"
      assert podcast.title == "some title"
      assert podcast.url == "some url"
      assert podcast.artwork == "some artwork"
      assert podcast.guid == "some guid"
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
        guid: "some updated guid"
      }

      assert {:ok, %Podcast{} = podcast} = Content.update_podcast(podcast, update_attrs)
      assert podcast.description == "some updated description"
      assert podcast.author == "some updated author"
      assert podcast.title == "some updated title"
      assert podcast.url == "some updated url"
      assert podcast.artwork == "some updated artwork"
      assert podcast.guid == "some updated guid"
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

  describe "episodes" do
    alias Rememcast.Content.Episode

    import Rememcast.ContentFixtures

    @invalid_attrs %{
      description: nil,
      title: nil,
      publish_date: nil,
      duration: nil,
      audio_url: nil,
      guid: nil,
      image: nil
    }

    test "list_episodes/0 returns all episodes" do
      episode = episode_fixture()
      assert Content.list_episodes() == [episode]
    end

    test "get_episode!/1 returns the episode with given id" do
      episode = episode_fixture()
      assert Content.get_episode!(episode.id) == episode
    end

    test "create_episode/1 with valid data creates a episode" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        publish_date: ~U[2025-11-15 16:43:00Z],
        duration: 42,
        audio_url: "some audio_url",
        guid: "some guid",
        image: "some image",
        podcast_id: podcast_fixture().id
      }

      assert {:ok, %Episode{} = episode} = Content.create_episode(valid_attrs)
      assert episode.description == "some description"
      assert episode.title == "some title"
      assert episode.publish_date == ~U[2025-11-15 16:43:00Z]
      assert episode.duration == 42
      assert episode.audio_url == "some audio_url"
      assert episode.guid == "some guid"
      assert episode.image == "some image"
    end

    test "create_episode/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_episode(@invalid_attrs)
    end

    test "update_episode/2 with valid data updates the episode" do
      episode = episode_fixture()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        publish_date: ~U[2025-11-16 16:43:00Z],
        duration: 43,
        audio_url: "some updated audio_url",
        guid: "some updated guid",
        image: "some updated image"
      }

      assert {:ok, %Episode{} = episode} = Content.update_episode(episode, update_attrs)
      assert episode.description == "some updated description"
      assert episode.title == "some updated title"
      assert episode.publish_date == ~U[2025-11-16 16:43:00Z]
      assert episode.duration == 43
      assert episode.audio_url == "some updated audio_url"
      assert episode.guid == "some updated guid"
      assert episode.image == "some updated image"
    end

    test "update_episode/2 with invalid data returns error changeset" do
      episode = episode_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_episode(episode, @invalid_attrs)
      assert episode == Content.get_episode!(episode.id)
    end

    test "delete_episode/1 deletes the episode" do
      episode = episode_fixture()
      assert {:ok, %Episode{}} = Content.delete_episode(episode)
      assert_raise Ecto.NoResultsError, fn -> Content.get_episode!(episode.id) end
    end

    test "change_episode/1 returns a episode changeset" do
      episode = episode_fixture()
      assert %Ecto.Changeset{} = Content.change_episode(episode)
    end
  end
end

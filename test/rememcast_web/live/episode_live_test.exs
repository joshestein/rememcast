defmodule RememcastWeb.EpisodeLiveTest do
  use RememcastWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rememcast.ContentFixtures

  @create_attrs %{
    description: "some description",
    title: "some title",
    publish_date: "2025-11-15T16:43:00Z",
    duration: 42,
    audio_url: "some audio_url",
    guid: "some guid",
    episode_number: 42,
    image: "some image"
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    publish_date: "2025-11-16T16:43:00Z",
    duration: 43,
    audio_url: "some updated audio_url",
    guid: "some updated guid",
    episode_number: 43,
    image: "some updated image"
  }
  @invalid_attrs %{
    description: nil,
    title: nil,
    publish_date: nil,
    duration: nil,
    audio_url: nil,
    guid: nil,
    episode_number: nil,
    image: nil
  }
  defp create_episode(_) do
    episode = episode_fixture()

    %{episode: episode}
  end

  describe "Index" do
    setup [:create_episode]

    test "lists all episodes", %{conn: conn, episode: episode} do
      {:ok, _index_live, html} = live(conn, ~p"/episodes")

      assert html =~ "Listing Episodes"
      assert html =~ episode.title
    end

    test "saves new episode", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/episodes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Episode")
               |> render_click()
               |> follow_redirect(conn, ~p"/episodes/new")

      assert render(form_live) =~ "New Episode"

      assert form_live
             |> form("#episode-form", episode: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#episode-form", episode: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/episodes")

      html = render(index_live)
      assert html =~ "Episode created successfully"
      assert html =~ "some title"
    end

    test "updates episode in listing", %{conn: conn, episode: episode} do
      {:ok, index_live, _html} = live(conn, ~p"/episodes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#episodes-#{episode.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/episodes/#{episode}/edit")

      assert render(form_live) =~ "Edit Episode"

      assert form_live
             |> form("#episode-form", episode: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#episode-form", episode: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/episodes")

      html = render(index_live)
      assert html =~ "Episode updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes episode in listing", %{conn: conn, episode: episode} do
      {:ok, index_live, _html} = live(conn, ~p"/episodes")

      assert index_live |> element("#episodes-#{episode.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#episodes-#{episode.id}")
    end
  end

  describe "Show" do
    setup [:create_episode]

    test "displays episode", %{conn: conn, episode: episode} do
      {:ok, _show_live, html} = live(conn, ~p"/episodes/#{episode}")

      assert html =~ "Show Episode"
      assert html =~ episode.title
    end

    test "updates episode and returns to show", %{conn: conn, episode: episode} do
      {:ok, show_live, _html} = live(conn, ~p"/episodes/#{episode}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/episodes/#{episode}/edit?return_to=show")

      assert render(form_live) =~ "Edit Episode"

      assert form_live
             |> form("#episode-form", episode: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#episode-form", episode: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/episodes/#{episode}")

      html = render(show_live)
      assert html =~ "Episode updated successfully"
      assert html =~ "some updated title"
    end
  end
end

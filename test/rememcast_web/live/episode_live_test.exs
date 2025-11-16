defmodule RememcastWeb.EpisodeLiveTest do
  use RememcastWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rememcast.ContentFixtures

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

    test "displays new episode search form", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/episodes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Episode")
               |> render_click()
               |> follow_redirect(conn, ~p"/episodes/new")

      html = render(form_live)
      assert html =~ "New Episode"
      assert html =~ "Search for new episodes"
      assert html =~ "What are you listening to?"
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
  end
end

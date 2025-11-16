defmodule RememcastWeb.PodcastLiveTest do
  use RememcastWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rememcast.ContentFixtures

  @create_attrs %{
    description: "some description",
    author: "some author",
    title: "some title",
    url: "some url",
    artwork: "some artwork",
    guid: "some guid"
  }
  @update_attrs %{
    description: "some updated description",
    author: "some updated author",
    title: "some updated title",
    url: "some updated url",
    artwork: "some updated artwork",
    guid: "some updated guid"
  }
  @invalid_attrs %{
    description: nil,
    author: nil,
    title: nil,
    url: nil,
    artwork: nil,
    guid: nil
  }
  defp create_podcast(_) do
    podcast = podcast_fixture()

    %{podcast: podcast}
  end

  describe "Index" do
    setup [:create_podcast]

    test "lists all podcasts", %{conn: conn, podcast: podcast} do
      {:ok, _index_live, html} = live(conn, ~p"/podcasts")

      assert html =~ "Listing Podcasts"
      assert html =~ podcast.title
    end

    test "saves new podcast", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/podcasts")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Podcast")
               |> render_click()
               |> follow_redirect(conn, ~p"/podcasts/new")

      assert render(form_live) =~ "New Podcast"

      assert form_live
             |> form("#podcast-form", podcast: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#podcast-form", podcast: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/podcasts")

      html = render(index_live)
      assert html =~ "Podcast created successfully"
      assert html =~ "some title"
    end

    test "updates podcast in listing", %{conn: conn, podcast: podcast} do
      {:ok, index_live, _html} = live(conn, ~p"/podcasts")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#podcasts-#{podcast.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/podcasts/#{podcast}/edit")

      assert render(form_live) =~ "Edit Podcast"

      assert form_live
             |> form("#podcast-form", podcast: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#podcast-form", podcast: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/podcasts")

      html = render(index_live)
      assert html =~ "Podcast updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes podcast in listing", %{conn: conn, podcast: podcast} do
      {:ok, index_live, _html} = live(conn, ~p"/podcasts")

      assert index_live |> element("#podcasts-#{podcast.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#podcasts-#{podcast.id}")
    end
  end

  describe "Show" do
    setup [:create_podcast]

    test "displays podcast", %{conn: conn, podcast: podcast} do
      {:ok, _show_live, html} = live(conn, ~p"/podcasts/#{podcast}")

      assert html =~ "Show Podcast"
      assert html =~ podcast.title
    end

    test "updates podcast and returns to show", %{conn: conn, podcast: podcast} do
      {:ok, show_live, _html} = live(conn, ~p"/podcasts/#{podcast}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/podcasts/#{podcast}/edit?return_to=show")

      assert render(form_live) =~ "Edit Podcast"

      assert form_live
             |> form("#podcast-form", podcast: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#podcast-form", podcast: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/podcasts/#{podcast}")

      html = render(show_live)
      assert html =~ "Podcast updated successfully"
      assert html =~ "some updated title"
    end
  end
end

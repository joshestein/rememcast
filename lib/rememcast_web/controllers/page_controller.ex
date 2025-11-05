defmodule RememcastWeb.PageController do
  use RememcastWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

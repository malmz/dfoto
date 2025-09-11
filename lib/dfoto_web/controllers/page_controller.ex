defmodule DfotoWeb.PageController do
  alias Dfoto.Gallery
  use DfotoWeb, :controller

  def home(conn, _params) do
    albums = Gallery.list_albums()

    conn
    |> assign(:albums, albums)
    |> render(:home)
  end
end

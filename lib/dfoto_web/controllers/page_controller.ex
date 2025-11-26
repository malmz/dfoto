defmodule DfotoWeb.PageController do
  alias Dfoto.Gallery
  use DfotoWeb, :controller

  def index(conn, _params) do
    albums = Gallery.all_albums!()

    conn
    |> assign(:albums, albums)
    |> render(:index)
  end

  def show(conn, %{"album_id" => album_id}) do
    album =
      Ash.get!(Gallery.Album, album_id)
      |> Ash.load!(:images)

    conn
    |> assign(:album, album)
    |> render(:show)
  end

  def image(conn, %{"album_id" => album_id, "image_id" => image_id}) do
    image =
      Ash.get!(Gallery.Image, image_id)

    conn
    |> assign(:image, image)
    |> render(:image)
  end
end

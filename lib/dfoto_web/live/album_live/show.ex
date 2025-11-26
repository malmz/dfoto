defmodule DfotoWeb.AlbumLive.Show do
  use DfotoWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Album {@album.id}
        <:subtitle>This is a album record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/albums"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/albums/#{@album}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Album
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@album.id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Album")
     |> assign(:album, Ash.get!(Dfoto.Gallery.Album, id))}
  end
end

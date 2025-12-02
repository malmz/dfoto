defmodule DfotoWeb.AlbumLive.Index do
  use DfotoWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Albums
        <:actions>
          <.button variant="primary" navigate={~p"/admin/albums/new"}>
            <.icon name="hero-plus" /> New Album
          </.button>
        </:actions>
      </.header>

      <.table
        id="albums"
        rows={@streams.albums}
        row_click={fn {_id, album} -> JS.navigate(~p"/admin/albums/#{album}") end}
      >
        <:col :let={{_id, album}} label="Id">{album.id}</:col>

        <:action :let={{_id, album}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/albums/#{album}"}>Show</.link>
          </div>

          <.link navigate={~p"/admin/albums/#{album}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, album}}>
          <.link
            phx-click={JS.push("delete", value: %{id: album.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Albums")
     |> assign_new(:current_user, fn -> nil end)
     |> stream(:albums, Ash.read!(Dfoto.Gallery.Album, actor: socket.assigns[:current_user]))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    album = Ash.get!(Dfoto.Gallery.Album, id, actor: socket.assigns.current_user)
    Ash.destroy!(album, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :albums, album)}
  end
end

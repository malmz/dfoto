defmodule DfotoWeb.AlbumLive.Form do
  use DfotoWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage album records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="album-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.button phx-disable-with="Saving..." variant="primary">Save Album</.button>
        <.button navigate={return_path(@return_to, @album)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    album =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Dfoto.Gallery.Album, id, actor: socket.assigns.current_user)
      end

    action = if is_nil(album), do: "New", else: "Edit"
    page_title = action <> " " <> "Album"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(album: album)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"album" => album_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, album_params))}
  end

  def handle_event("save", %{"album" => album_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: album_params) do
      {:ok, album} ->
        notify_parent({:saved, album})

        socket =
          socket
          |> put_flash(:info, "Album #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, album))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{album: album}} = socket) do
    form =
      if album do
        AshPhoenix.Form.for_update(album, :update,
          as: "album",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Dfoto.Gallery.Album, :create,
          as: "album",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _album), do: ~p"/albums"
  defp return_path("show", album), do: ~p"/albums/#{album.id}"
end

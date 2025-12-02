defmodule DfotoWeb.AlbumLive.Form do
  require Logger
  alias Dfoto.Gallery
  use DfotoWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title} <span :if={@album} class="badge badge-primary">{@album.status}</span>
        <:subtitle>Use this form to manage album records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="album-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.input type="text" field={@form[:title]} />
        <.input type="textarea" field={@form[:description]} />
        <.button phx-disable-with="Saving..." variant="primary">
          Save Album
        </.button>
        <%= if @album do %>
          <%= case @album.status do %>
            <% :draft -> %>
              <.button
                type="button"
                phx-click="publish"
                phx-disable-with="Publishing..."
                variant="warning"
              >
                Publish
              </.button>
            <% :published -> %>
              <.button
                type="button"
                phx-click="unpublish"
                phx-disable-with="Unpublishing..."
                variant="warning"
              >
                Unpublish
              </.button>
            <% :archived -> %>
              <.button
                type="button"
                phx-click="unarchive"
                phx-disable-with="Unarchiving..."
                variant="warning"
              >
                Unarchive
              </.button>
          <% end %>
        <% end %>
      </.form>

      <section phx-drop-target={@uploads.images.ref} class="">
        <div :for={entry <- @uploads.images.entries} class="card shadow-sm">
          <figure>
            <.live_img_preview entry={entry} />
          </figure>
          <div class="card-body flex-row justify-center">
            <progress value={entry.progress} max="100" class="progress">{entry.progress}% </progress>
            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
              class="btn btn-square"
            >
              <.icon name="hero-x-mark" />
            </button>
            <p :for={err <- upload_errors(@uploads.images, entry)} class="alert alert-danger">
              {error_to_string(err)}
            </p>
          </div>
        </div>

        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <p :for={err <- upload_errors(@uploads.images)} class="alert alert-danger">
          {error_to_string(err)}
        </p>
      </section>
      <form id="upload-form" phx-submit="save_upload" phx-change="validate_upload">
        <.live_file_input upload={@uploads.images} class="file-input" />
        <.button variant="primary">Upload</.button>
      </form>

      <div :if={@album}>
        <figure :for={image <- @album.images}>
          <img src={image_path(image)} />
        </figure>
      </div>
    </Layouts.app>
    """
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    album =
      case params["id"] do
        nil ->
          nil

        id ->
          Ash.get!(Dfoto.Gallery.Album, id)
          |> Ash.load!(:images)
      end

    action = if is_nil(album), do: "New", else: "Edit"

    page_title = action <> " " <> "Album"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(album: album)
     |> assign(:page_title, page_title)
     |> assign(:uploaded_files, [])
     |> allow_upload(:images, accept: ~w(.jpg .jpeg .png), max_entries: 50)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl Phoenix.LiveView
  def handle_event("validate", %{"album" => album_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, album_params))}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"album" => album_params}, socket) do
    case dbg(AshPhoenix.Form.submit(socket.assigns.form, params: album_params)) do
      {:ok, album} ->
        # notify_parent({:saved, album})
        album = Ash.load!(album, :images)

        socket =
          socket
          |> assign(:album, album)
          |> put_flash(:info, "Album #{socket.assigns.form.source.type}d successfully")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("publish", _params, socket) do
    album = socket.assigns[:album]

    case Gallery.publish_album(album) do
      {:ok, album} ->
        socket =
          socket
          |> assign(album: album)
          |> put_flash(:info, "Album has been published")

        {:noreply, socket}

      {:error, cause} ->
        Logger.error(cause)

        {:noreply,
         socket
         |> put_flash(:error, "Could not publish album")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("unpublish", _params, socket) do
    album = socket.assigns[:album]

    case Gallery.unpublish_album(album) do
      {:ok, album} ->
        socket =
          socket
          |> assign(album: album)
          |> put_flash(:info, "Album has been unpublished")

        {:noreply, socket}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not unpublish album")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("unarchive", _params, socket) do
    album = socket.assigns[:album]

    case Gallery.unarchive_album(album) do
      {:ok, album} ->
        socket =
          socket
          |> assign(album: album)
          |> put_flash(:info, "Album has been unarchived")

        {:noreply, socket}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not unarchive album")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate_upload", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save_upload", _params, socket) do
    consume_uploaded_entries(socket, :images, fn meta, entry ->
      case Gallery.upload_image(%{
             file_path: meta.path,
             album_id: socket.assigns.album.id,
             original_file_name: entry.client_name
           }) do
        {:ok, image} ->
          {:ok, "/media/preview/#{image.album_id}/#{image.id}.webp"}

        {:error, reason} ->
          {:error, reason}
      end
    end)

    {:noreply, update(socket, :album, &Ash.load!(&1, :images))}
  end

  defp assign_form(%{assigns: %{album: album}} = socket) do
    form =
      if album do
        AshPhoenix.Form.for_update(album, :update,
          as: "album"
          # actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Dfoto.Gallery.Album, :create,
          as: "album"
          # actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _album), do: ~p"/albums"
  defp return_path("show", album), do: ~p"/albums/#{album.id}"

  defp image_path(%{id: image_id, album_id: album_id}),
    do: "/media/preview/#{album_id}/#{image_id}.webp"

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end

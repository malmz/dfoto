defmodule DfotoWeb.AlbumLive.Form do
  require Logger
  alias Dfoto.Gallery
  use DfotoWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <span :if={@album} class={"badge #{badge_color(@album.status)}"}>{@album.status}</span>
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
      </.form>

      <div class="flex flex-wrap gap-1 mb-4 sm:justify-between">
        <form id="upload-form" phx-change="validate_upload" phx-submit="save_upload" class="inline">
          <label
            for={@uploads.images.ref}
            phx-drop-target={@uploads.images.ref}
            class="btn btn-primary btn-block"
          >
            Upload image
          </label>
          <.live_file_input upload={@uploads.images} class="hidden" />
        </form>

        <div class="contents sm:block">
          <.button form="album-form" phx-disable-with="Saving..." variant="primary">
            Save Album
          </.button>

          <%= if @album do %>
            <%= case @album.status do %>
              <% :draft -> %>
                <.button
                  form="album-form"
                  type="button"
                  phx-click="publish"
                  phx-disable-with="Publishing..."
                  variant="warning"
                >
                  Publish
                </.button>
              <% :published -> %>
                <.button
                  form="album-form"
                  type="button"
                  phx-click="unpublish"
                  phx-disable-with="Unpublishing..."
                  variant="warning"
                >
                  Unpublish
                </.button>
              <% :archived -> %>
                <.button
                  form="album-form"
                  type="button"
                  phx-click="unarchive"
                  phx-disable-with="Unarchiving..."
                  variant="warning"
                >
                  Unarchive
                </.button>
            <% end %>
          <% end %>
        </div>
      </div>

      <section>
        <div class="grid sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
          <div
            :for={image <- @album.images}
            :if={@album}
            data-thumbnail={@album.thumbnail_id == image.id}
            class="card card-border bg-base-300 card-xs data-thumbnail:outline-2 outline-dashed outline-accent"
          >
            <figure class="bg-neutral-800">
              <img src={image_path(image)} />
            </figure>
            <div class="card-body">
              <div class="card-actions justify-between">
                <div>
                  <.button
                    navigate={~p"/admin/albums/#{@album.id}/#{image.id}"}
                    variant="primary"
                    size="xs"
                  >
                    Edit
                  </.button>
                  <%= if @album.thumbnail_id == image.id do %>
                    <.button
                      variant="primary"
                      size="xs"
                      disabled
                    >
                      Thumb set
                    </.button>
                  <% else %>
                    <.button
                      phx-click="set-thumbnail"
                      phx-value-image_id={image.id}
                      variant="primary"
                      size="xs"
                    >
                      Set thumb
                    </.button>
                  <% end %>
                </div>
                <button class="btn btn-warning btn-xs">
                  Delete
                </button>
              </div>
            </div>
          </div>
          <div :for={entry <- @uploads.images.entries} class="card card-border">
            <figure>
              <.live_img_preview entry={entry} />
            </figure>
            <div class="card-action">
              <progress value={entry.progress} max="100" class="progress progress-primary">
                {entry.progress}%
              </progress>
              <button
                type="button"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                aria-label="cancel"
                class="btn btn-square btn-warning"
              >
                <.icon name="hero-x-mark" />
              </button>
              <p :for={err <- upload_errors(@uploads.images, entry)} class="alert alert-danger">
                {error_to_string(err)}
              </p>
            </div>
          </div>
        </div>

        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <p :for={err <- upload_errors(@uploads.images)} class="alert alert-danger">
          {error_to_string(err)}
        </p>
      </section>
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
     |> allow_upload(:images,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 50,
       auto_upload: true,
       progress: &handle_progress/3
     )
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp handle_progress(:images, entry, socket) do
    if entry.done? do
      consume_uploaded_entry(socket, entry, fn %{} = meta ->
        case Gallery.upload_image(%{
               file_path: meta.path,
               album_id: socket.assigns.album.id,
               original_file_name: entry.client_name
             }) do
          {:ok, image} ->
            {:ok, "/media/thumbnail/#{image.album_id}/#{image.id}.webp"}

          {:error, reason} ->
            {:error, reason}
        end
      end)

      socket =
        socket
        |> update(:album, &Ash.load!(&1, :images))
        |> put_flash(:info, "uploaded file #{entry.client_name}")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

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
  def handle_event("set-thumbnail", %{"image_id" => image_id}, socket) do
    socket =
      socket
      |> update(:album, &Gallery.set_thumbnail!(&1, image_id))

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_upload", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save_upload", _params, socket) do
    {:noreply, socket}
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
    do: "/media/thumbnail/#{album_id}/#{image_id}.webp"

  defp badge_color(:published), do: "badge-success"
  defp badge_color(:draft), do: "badge-primary"
  defp badge_color(:archived), do: "badge-danger"

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end

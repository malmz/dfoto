defmodule Dfoto.Gallery.PreviewReactor do
  alias Dfoto.Gallery.Paths
  use Reactor, extensions: [Reactor.File]
  use OK.Pipe

  input :album_id
  input :image_id
  input :original_path

  step :folder_path do
    argument :album_id, input(:album_id)

    run fn %{album_id: album_id} ->
      {:ok, Paths.preview_path(album_id)}
    end
  end

  mkdir_p :ensure_folder do
    path result(:folder_path)
  end

  step :destination_path do
    argument :album_id, input(:album_id)
    argument :image_id, input(:image_id)

    run fn %{album_id: album_id, image_id: image_id} ->
      {:ok, Paths.preview_path(album_id, image_id)}
    end
  end

  step :generate do
    wait_for :ensure_folder
    argument :orig, input(:original_path)
    argument :target, result(:destination_path)

    run fn %{orig: orig, target: target} ->
      Image.thumbnail(orig, "1200x800", fit: :contain)
      ~>> Image.write(target)
    end
  end

  return :destination_path
end

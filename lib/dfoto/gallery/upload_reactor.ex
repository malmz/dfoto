defmodule Dfoto.Gallery.UploadReactor do
  alias Dfoto.Gallery.Paths
  alias Dfoto.Gallery
  use Reactor, extensions: [Ash.Reactor, Reactor.File]

  input :file_path
  input :album_id
  input :original_file_name

  create :create_image, Gallery.Image, :create do
    inputs %{filename: input(:original_file_name), album_id: input(:album_id)}
    undo :outside_transaction
    undo_action :destroy
  end

  step :image_folder do
    argument :album_id, input(:album_id)
    run fn %{album_id: album_id} -> {:ok, Paths.image_path(album_id)} end
  end

  mkdir_p :ensure_image_folder do
    path result(:image_folder)
  end

  step :destination_image_name do
    argument :album_id, input(:album_id)
    argument :image_id, result(:create_image, [:id])
    argument :file_name, input(:original_file_name)

    run fn %{album_id: album_id, image_id: image_id, file_name: file_name} ->
      {:ok, Paths.image_path(album_id, image_id, file_name)}
    end
  end

  cp :copy_to_album_folder do
    wait_for :ensure_image_folder
    source input(:file_path)
    target result(:destination_image_name)
    revert_on_undo? true
  end

  compose :generate_thumbnail, Gallery.ThumbnailReactor do
    argument :album_id, input(:album_id)
    argument :image_id, result(:create_image, [:id])
    argument :original_path, input(:file_path)
  end

  compose :generate_preview, Gallery.PreviewReactor do
    argument :album_id, input(:album_id)
    argument :image_id, result(:create_image, [:id])
    argument :original_path, input(:file_path)
  end

  return :create_image
end

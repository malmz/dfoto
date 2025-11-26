defmodule Dfoto.Gallery.UploadReactor do
  alias Dfoto.Gallery
  use Reactor, extensions: [Ash.Reactor, Reactor.File]

  @storage_path "storage"
  @folder_name "images"

  input :file_path
  input :album_id
  input :original_file_name

  step :file_extension do
    argument :file_name, input(:original_file_name)
    run fn %{file_name: file_name} -> {:ok, Path.extname(file_name)} end
  end

  create :create_image, Gallery.Image, :create do
    inputs %{filename: input(:original_file_name), album_id: input(:album_id)}
    undo :outside_transaction
    undo_action :destroy
  end

  step :image_folder do
    argument :album_id, input(:album_id)
    run fn %{album_id: album_id} -> {:ok, Path.join([@storage_path, @folder_name, album_id])} end
  end

  step :destination_image_name do
    argument :base, result(:image_folder)
    argument :image, result(:create_image, [:id])
    argument :ext, result(:file_extension)

    run fn %{base: base, image: image, ext: ext} ->
      {:ok, Path.join(base, "#{image}#{ext}")}
    end
  end

  mkdir_p :ensure_image_folder do
    path result(:image_folder)
  end

  cp :copy_to_album_folder do
    wait_for :ensure_image_folder
    source input(:file_path)
    target result(:destination_image_name)
    revert_on_undo? true
  end

  compose :generate_thumbnail, Gallery.ThumbnailReactor do
    wait_for :copy_to_album_folder
    argument :base_path, value(@storage_path)
    argument :album_id, input(:album_id)
    argument :image_id, result(:create_image, [:id])
    argument :original_path, result(:destination_image_name)
  end

  compose :generate_preview, Gallery.PreviewReactor do
    wait_for :copy_to_album_folder
    argument :base_path, value(@storage_path)
    argument :album_id, input(:album_id)
    argument :image_id, result(:create_image, [:id])
    argument :original_path, result(:destination_image_name)
  end

  return :create_image
end

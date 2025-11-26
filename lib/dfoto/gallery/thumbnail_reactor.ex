defmodule Dfoto.Gallery.ThumbnailReactor do
  use Reactor, extensions: [Reactor.File]
  use OK.Pipe

  @folder_name "thumbnail"

  input :base_path
  input :album_id
  input :image_id
  input :original_path

  step :folder_path do
    argument :base_path, input(:base_path)
    argument :album_id, input(:album_id)

    run fn %{base_path: base_path, album_id: album_id} ->
      {:ok, Path.join([base_path, @folder_name, album_id])}
    end
  end

  mkdir_p :ensure_folder do
    path result(:folder_path)
  end

  step :destination_path do
    argument :base, result(:folder_path)
    argument :image, input(:image_id)

    run fn %{base: base, image: image} ->
      {:ok, Path.join(base, "#{image}.webp")}
    end
  end

  step :generate do
    wait_for :ensure_folder
    argument :orig, input(:original_path)
    argument :target, result(:destination_path)

    run fn %{orig: orig, target: target} ->
      Image.thumbnail(orig, "300x200", fit: :cover, crop: :attention)
      ~>> Image.write(target)
    end
  end

  return :destination_path
end

defmodule Dfoto.Gallery.Paths do
  @moduledoc """
  Utilities for getting the right path to images
  """

  @storage_path "storage"
  @image_path "image"
  @preview_path "preview"
  @thumbnail_path "thumbnail"

  @spec image_path(binary()) :: binary()
  def image_path(album_id) do
    Path.join([@storage_path, @image_path, album_id])
  end

  @spec image_path(binary(), binary(), binary()) :: binary()
  def image_path(album_id, image_id, filename) do
    ext = Path.extname(filename)
    name = "#{image_id}#{ext}"
    Path.join(image_path(album_id), name)
  end

  @spec preview_path(binary()) :: binary()
  def preview_path(album_id) do
    Path.join([@storage_path, @preview_path, album_id])
  end

  @spec preview_path(binary(), binary()) :: binary()
  def preview_path(album_id, image_id) do
    name = "#{image_id}.webp"
    Path.join(preview_path(album_id), name)
  end

  @spec thumbnail_path(binary()) :: binary()
  def thumbnail_path(album_id) do
    Path.join([@storage_path, @thumbnail_path, album_id])
  end

  @spec thumbnail_path(binary(), binary()) :: binary()
  def thumbnail_path(album_id, image_id) do
    name = "#{image_id}.webp"
    Path.join(thumbnail_path(album_id), name)
  end
end

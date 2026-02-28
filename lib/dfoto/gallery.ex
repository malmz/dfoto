defmodule DFoto.Gallery do
  use Ash.Domain, otp_app: :dfoto

  resources do
    resource DFoto.Gallery.Album do
      define :all_albums, action: :read
      define :published_albums, action: :published
      define :search_albums, args: [:query], action: :search
      define :publish_album, action: :publish
      define :unpublish_album, action: :unpublish
      define :archive_album, action: :archive
      define :unarchive_album, action: :unarchive
      define :set_thumbnail, args: [:image_id], action: :thumbnail
    end

    resource DFoto.Gallery.Image do
      define :upload_image, action: :upload
    end

    resource DFoto.Gallery.Legacy.Album
    resource DFoto.Gallery.Legacy.Image
    resource DFoto.Gallery.OrderedImage
  end
end

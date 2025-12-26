defmodule Dfoto.Gallery do
  use Ash.Domain, otp_app: :dfoto

  resources do
    resource Dfoto.Gallery.Album do
      define :all_albums, action: :read
      define :published_albums, action: :published
      define :search_albums, args: [:query], action: :search
      define :publish_album, action: :publish
      define :unpublish_album, action: :unpublish
      define :archive_album, action: :archive
      define :unarchive_album, action: :unarchive
      define :set_thumbnail, args: [:image_id], action: :thumbnail
    end

    resource Dfoto.Gallery.Image do
      define :upload_image, action: :upload
    end

    resource Dfoto.Gallery.Legacy.Album
    resource Dfoto.Gallery.Legacy.Image
    resource Dfoto.Gallery.OrderedImage
  end
end

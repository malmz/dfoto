defmodule Dfoto.Gallery do
  use Ash.Domain, otp_app: :dfoto, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Dfoto.Gallery.Album do
      define :published_albums, action: :published
    end

    resource Dfoto.Gallery.Image
  end
end

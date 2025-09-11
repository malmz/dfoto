defmodule Dfoto.Gallery do
  use Ash.Domain, otp_app: :dfoto

  resources do
    resource Dfoto.Gallery.Album
    resource Dfoto.Gallery.Image
  end
end

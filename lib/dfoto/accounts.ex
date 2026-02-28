defmodule DFoto.Accounts do
  use Ash.Domain, otp_app: :dfoto

  resources do
    resource DFoto.Accounts.User
  end
end

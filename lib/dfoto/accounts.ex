defmodule Dfoto.Accounts do
  use Ash.Domain, otp_app: :dfoto

  resources do
    resource Dfoto.Accounts.User
  end
end

defmodule Dfoto.Accounts do
  use Ash.Domain, otp_app: :dfoto, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Dfoto.Accounts.User
  end
end

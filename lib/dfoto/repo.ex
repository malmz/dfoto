defmodule DFoto.Repo do
  use Ecto.Repo,
    otp_app: :dfoto,
    adapter: Ecto.Adapters.Postgres
end

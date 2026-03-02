defmodule DFoto.Repo do
  use Ecto.Repo,
    otp_app: :dfoto,
    adapter: Ecto.Adapter.Postgres
end

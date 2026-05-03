defmodule Dfoto.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :authentik_id, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:authentik_id, :name])
    |> validate_required([:authentik_id, :name])
  end
end

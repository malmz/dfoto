defmodule Dfoto.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @roles [dfoto: "dfoto", asp: "dfoto-asp"]

  schema "users" do
    field :authentik_id, :string
    field :name, :string
    field :authenticated_at, :utc_datetime, virtual: true
    field :roles, {:array, Ecto.Enum}, values: @roles, virtual: true

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:authentik_id, :name])
    |> validate_required([:authentik_id, :name])
  end
end

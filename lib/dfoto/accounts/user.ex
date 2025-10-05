defmodule Dfoto.Accounts.User do
  use Ash.Resource,
    otp_app: :dfoto,
    domain: Dfoto.Accounts,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo Dfoto.Repo
  end

  actions do
    defaults [:read]

    create :login do
      argument :user_info, :map, allow_nil?: false
      argument :tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :authentik_id

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        changeset
        |> Ash.Changeset.change_attributes(Map.take(user_info, ["name"]))
        |> Ash.Changeset.change_attribute(:authentik_id, user_info["sub"])
      end
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :authentik_id, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
  end

  identities do
    identity :authentik_id, [:authentik_id]
  end
end

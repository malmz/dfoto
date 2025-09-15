defmodule Dfoto.Accounts.User do
  use Ash.Resource,
    otp_app: :dfoto,
    domain: Dfoto.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication]

  authentication do
    strategies do
      oidc :authentik do
        client_id Dfoto.Secrets
        client_secret Dfoto.Secrets
        redirect_uri Dfoto.Secrets
        base_url Dfoto.Secrets
      end
    end

    tokens do
      enabled? true
      token_resource Dfoto.Accounts.Token
      signing_secret Dfoto.Secrets
      store_all_tokens? true
      require_token_presence_for_authentication? true
    end
  end

  postgres do
    table "users"
    repo Dfoto.Repo
  end

  actions do
    defaults [:read]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end

    create :register_with_authentik do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :authentik_id

      change AshAuthentication.GenerateTokenChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        changeset
        |> Ash.Changeset.change_attributes(Map.take(user_info, ["name", "roles"]))
        |> Ash.Changeset.change_attribute(:authentik_id, user_info["sub"])
      end
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      forbid_if always()
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

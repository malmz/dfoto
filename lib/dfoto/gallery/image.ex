defmodule Dfoto.Gallery.Image do
  use Ash.Resource,
    domain: Dfoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "images"
    repo Dfoto.Repo
    identity_wheres_to_sql single_thumbnail: "is_thumbnail"
  end

  validations do
    validate negate(present(:photographer_guest_name)) do
      where present(:photographer)
    end
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :photographer_guest_name, :string

    attribute :taken_at, :datetime do
      default &DateTime.utc_now/0
    end

    attribute :is_thumbnail, :boolean

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :album, Dfoto.Gallery.Album
    belongs_to :photographer, Dfoto.Accounts.User
    belongs_to :user, Dfoto.Accounts.User
  end

  calculations do
    calculate :photographer_name,
              :string,
              expr(photographer_guest_name || photographer.name || "Unknown")
  end

  identities do
    identity :single_thumbnail, [:album_id], where: expr(is_thumbnail)
  end
end

defmodule Dfoto.Gallery.Legacy.Image do
  use Ash.Resource,
    domain: Dfoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "legacy_images"
    repo Dfoto.Repo
  end

  attributes do
    attribute :legacy_id, :string do
      public? true
      allow_nil? false
    end
  end

  relationships do
    belongs_to :image, Dfoto.Gallery.Image do
      primary_key? true
      source_attribute :id
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_legacy_id, [:legacy_id]
  end
end

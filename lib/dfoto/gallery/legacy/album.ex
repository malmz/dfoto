defmodule DFoto.Gallery.Legacy.Album do
  use Ash.Resource,
    domain: DFoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "legacy_albums"
    repo DFoto.Repo
  end

  attributes do
    attribute :legacy_id, :string do
      public? true
      allow_nil? false
    end
  end

  relationships do
    belongs_to :album, DFoto.Gallery.Album do
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

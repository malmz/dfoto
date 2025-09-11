defmodule Dfoto.Gallery.Album do
  use Ash.Resource,
    domain: Dfoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "albums"
    repo Dfoto.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
    default_accept [:title, :description]

    read :published do
      filter expr(state == :published)
      pagination required?: false, offset?: true, keyset?: true
    end

    update :publish do
      set_attribute(:state, :published)
    end

    update :unpublish do
      set_attribute(:state, :draft)
    end

    update :archive do
      set_attribute(:state, :archived)
    end

    read :all
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :title, :string
    attribute :description, :string

    attribute :state, :atom do
      constraints one_of: [:draft, :published, :archived]
      default :draft
    end

    attribute :start_at, :datetime
    create_timestamp :created_at
    update_timestamp :modified_at
  end

  relationships do
    has_many :images, Dfoto.Gallery.Image

    has_one :thumbnail, Dfoto.Gallery.Image do
      no_attributes? true
      filter expr(is_thumbnail)
    end
  end
end

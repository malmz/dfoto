defmodule Dfoto.Gallery.Album do
  use Ash.Resource,
    domain: Dfoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "album"
    repo Dfoto.Repo
  end

  actions do
    defaults [:destroy, create: :*, update: :*]

    read :published do
      filter expr(status == :published)
    end

    update :publish do
      set_attribute(:status, :published)
    end

    update :unpublish do
      set_attribute(:status, :draft)
    end

    update :archive do
      set_attribute(:status, :archived)
    end

    read :all
  end

  attributes do
    integer_primary_key :id
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

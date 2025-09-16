defmodule Dfoto.Gallery.Album do
  use Ash.Resource,
    domain: Dfoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "albums"
    repo Dfoto.Repo
  end

  actions do
    default_accept [:title, :description, :start_at, :status]
    defaults [:read, :destroy, create: :*, update: :*]

    read :all do
      # primary? true
      pagination required?: false, offset?: true, keyset?: true
    end

    read :published do
      filter expr(status == :published)
      pagination required?: false, offset?: true, keyset?: true
    end

    update :publish do
      accept []

      validate attribute_does_not_equal(:status, :published) do
        message "Album is already published"
      end

      set_attribute(:status, :published)
    end

    update :unpublish do
      accept []

      validate attribute_does_not_equal(:status, :draft) do
        message "Album is already a draft"
      end

      set_attribute(:status, :draft)
    end

    update :archive do
      accept []

      validate attribute_does_not_equal(:status, :archived) do
        message "Album is already archived"
      end

      set_attribute(:status, :archived)
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string do
      allow_nil? false
    end

    attribute :status, :atom do
      constraints one_of: [:draft, :published, :archived]
      default :draft
      allow_nil? false
    end

    attribute :start_at, :datetime do
      allow_nil? false
      default &DateTime.utc_now/0
      match_other_defaults? true
    end

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

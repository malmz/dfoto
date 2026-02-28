defmodule Dfoto.Gallery.Album do
  use Ash.Resource,
    domain: Dfoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "albums"
    repo Dfoto.Repo

    custom_statements do
      statement :search_index do
        up "CREATE INDEX albums_search_idx ON albums USING GIN (to_tsvector('swedish', title || ' ' || description));"
        down "DROP INDEX albums_search_idx;"
      end
    end
  end

  actions do
    default_accept [:title, :description, :start_at, :status]
    defaults [:destroy, create: :*, update: :*]

    read :read do
      primary? true
      pagination required?: false, offset?: true, keyset?: true
    end

    read :published do
      filter expr(status == :published)
      pagination required?: false, offset?: true, keyset?: true
    end

    read :search do
      argument :query, :string

      filter expr(status == :published)

      filter expr(
               fragment(
                 "to_tsvector('swedish', title || ' ' || description) @@ websearch_to_tsquery('swedish', ?)",
                 ^arg(:query)
               )
             )

      prepare build(sort: [search_rank: {%{search_query: arg(:query)}, :asc}])
      pagination required?: false, offset?: true, keyset?: true
    end

    update :publish do
      accept []

      validate attribute_does_not_equal(:status, :published) do
        message "Album is already published"
      end

      change atomic_update(:thumbnail_id, expr(first(images, field: :id))) do
        where [attributes_absent(:thumbnail_id)]
      end

      change set_attribute(:status, :published)
    end

    update :unpublish do
      accept []

      validate attribute_equals(:status, :published) do
        message "Album is not published"
      end

      change set_attribute(:status, :draft)
    end

    update :archive do
      accept []

      validate attribute_does_not_equal(:status, :archived) do
        message "Album is already archived"
      end

      change set_attribute(:status, :archived)
    end

    update :unarchive do
      accept []

      validate attribute_equals(:status, :archived) do
        message "Album is not archived"
      end
    end

    update :thumbnail do
      accept []
      argument :image_id, :uuid

      change set_attribute(:thumbnail_id, arg(:image_id))
    end

    update :remove_image do
      accept []
      require_atomic? false
      argument :image_id, :uuid

      change manage_relationship(:image_id, :images, type: :remove)
    end
  end

  changes do
    change optimistic_lock(:version), on: [:create, :update, :destroy]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      allow_nil? false
      public? true
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
      public? true
    end

    attribute :version, :integer do
      allow_nil? false
      default 1
    end

    create_timestamp :created_at
    update_timestamp :modified_at
  end

  relationships do
    has_many :images, Dfoto.Gallery.Image
    belongs_to :thumbnail, Dfoto.Gallery.Image
  end

  calculations do
    calculate :search_rank,
              :float,
              expr(
                fragment(
                  "ts_rank_cd(to_tsvector('swedish_hunspell', title || ' ' || description), websearch_to_tsquery('swedish_hunspell', ?))",
                  ^arg(:search_query)
                )
              ) do
      argument :search_query, :string
    end
  end
end

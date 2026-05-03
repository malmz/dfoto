defmodule Dfoto.Gallery.OrderedImage do
  use Ash.Resource,
    domain: Dfoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ordered_images"
    repo Dfoto.Repo
    migrate? false
  end

  actions do
    defaults [:read]
  end

  attributes do
    uuid_v7_primary_key :id
  end

  relationships do
    belongs_to :image, Dfoto.Gallery.Image do
      source_attribute :id
      define_attribute? false
    end

    belongs_to :prev_image, Dfoto.Gallery.Image do
      source_attribute :prev_id
    end

    belongs_to :next_image, Dfoto.Gallery.Image do
      source_attribute :next_id
    end
  end
end

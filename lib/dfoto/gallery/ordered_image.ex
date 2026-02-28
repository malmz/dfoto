defmodule DFoto.Gallery.OrderedImage do
  use Ash.Resource,
    domain: DFoto.Gallery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ordered_images"
    repo DFoto.Repo
    migrate? false
  end

  actions do
    defaults [:read]
  end

  attributes do
    uuid_v7_primary_key :id
  end

  relationships do
    belongs_to :image, DFoto.Gallery.Image do
      source_attribute :id
      define_attribute? false
    end

    belongs_to :prev_image, DFoto.Gallery.Image do
      source_attribute :prev_id
    end

    belongs_to :next_image, DFoto.Gallery.Image do
      source_attribute :next_id
    end
  end
end

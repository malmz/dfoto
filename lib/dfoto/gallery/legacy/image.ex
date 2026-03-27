defmodule DFoto.Gallery.Legacy.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "legacy_images" do
    field :legacy_id, :string
    belongs_to :image, DFoto.Gallery.Image, primary_key: true
  end

  def changeset(legacy_image, attrs) do
    legacy_image
    |> cast(attrs, [:legacy_id])
    |> validate_required([:legacy_id])
  end
end

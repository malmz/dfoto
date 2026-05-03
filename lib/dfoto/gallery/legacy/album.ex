defmodule DFoto.Gallery.Legacy.Album do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "legacy_albums" do
    field :legacy_id, :string
    belongs_to :album, DFoto.Gallery.Album, primary_key: true
  end

  def changeset(legacy_album, attrs) do
    legacy_album
    |> cast(attrs, [:legacy_id])
    |> validate_required([:legacy_id])
  end
end

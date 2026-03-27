defmodule DFoto.Gallery.Album do
  use Ecto.Schema
  import Ecto.Changeset

  alias DFoto.Accounts.Scope

  schema "albums" do
    field :title, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:draft, :published, :archived], default: :draft
    field :start_at, :utc_datetime
    field :version, :integer, default: 1

    has_many :images, DFoto.Gallery.Image
    belongs_to :thumbnail, DFoto.Gallery.Image
    has_one :legacy, DFoto.Gallery.Legacy.Album

    timestamps(type: :utc_datetime)
  end

  def changeset(album, attrs, %Scope{} = _scope) do
    album
    |> cast(attrs, [:title, :description, :status, :start_at, :version])
    |> validate_required([:title, :description, :status, :start_at])
    |> validate_inclusion(:status, [:draft, :published, :archived])
    |> optimistic_lock(:version)
  end

  def legacy_changeset(album, attrs, %Scope{} = scope) do
    album
    |> changeset(attrs, scope)
    |> cast_assoc(:legacy)
  end
end

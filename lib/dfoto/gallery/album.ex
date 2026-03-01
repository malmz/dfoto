defmodule DFoto.Gallery.Album do
  use Ecto.Schema
  import Ecto.Changeset

  alias DFoto.Gallery.Image

  schema "albums" do
    field :title, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:draft, :published, :archived], default: :draft
    field :start_at, :utc_datetime
    field :version, :integer, default: 1

    has_many :images, Image
    belongs_to :thumbnail, Image

    timestamps type: :utc_datetime
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          status: :draft | :published | :archived | nil,
          start_at: DateTime.t() | nil,
          version: integer() | nil,
          thumbnail_id: Ecto.UUID.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  def changeset(album, attrs) do
    album
    |> cast(attrs, [:title, :description, :status, :start_at, :version, :thumbnail_id])
    |> validate_required([:title, :description, :status, :start_at])
    |> validate_inclusion(:status, [:draft, :published, :archived])
    |> optimistic_lock(:version)
  end
end

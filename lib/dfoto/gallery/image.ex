defmodule Dfoto.Gallery.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :filename, :string
    field :photographer_guest_name, :string
    field :taken_at, :utc_datetime
    field :version, :integer, default: 1

    belongs_to :album, Dfoto.Gallery.Album
    belongs_to :user, Dfoto.Accounts.User
    belongs_to :photographer, Dfoto.Accounts.User
    has_one :thumbnail, Dfoto.Gallery.Album, foreign_key: :thumbnail_id
    has_one :legacy, Dfoto.Gallery.Legacy.Image

    timestamps(type: :utc_datetime)
  end

  def changeset(image, attrs, scope) do
    image
    |> cast(attrs, [:filename, :photographer_guest_name, :taken_at])
    |> validate_required([:filename])
    |> optimistic_lock(:version)
    |> put_assoc(:user, scope.user)
  end

  def legacy_changeset(image, attrs, scope) do
    image
    |> changeset(attrs, scope)
    |> cast_assoc(:legacy)
  end

  @old """
  actions do
    defaults [:read, update: :*]

    create :create do
      accept [:filename, :taken_at]
      argument :album_id, :uuid

      change manage_relationship(:album_id, :album, type: :append_and_remove)
    end

    action :upload, :struct do
      constraints instance_of: __MODULE__
      argument :album_id, :uuid, allow_nil?: false
      argument :file_path, :string, allow_nil?: false
      argument :original_file_name, :string, allow_nil?: false

      run UploadReactor
    end

    destroy :destroy do
      accept []
      require_atomic? false

      change after_action(fn changeset, image ->
               with :ok <- File.rm(Paths.image_path(image.album_id, image.id, image.filename)),
                    :ok <- File.rm(Paths.preview_path(image.album_id, image.id)),
                    :ok <- File.rm(Paths.thumbnail_path(image.album_id, image.id)) do
                 {:ok, image}
               end
             end)
    end
  end

  changes do
    change optimistic_lock(:version), on: [:create, :update, :destroy]
  end

  validations do
    validate negate(present(:photographer_guest_name)) do
      where present(:photographer)
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :filename, :string, public?: true

    attribute :photographer_guest_name, :string

    attribute :taken_at, :datetime do
      allow_nil? false
      default &DateTime.utc_now/0
    end

    attribute :version, :integer do
      allow_nil? false
      default 1
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :album, Dfoto.Gallery.Album
    belongs_to :photographer, Dfoto.Accounts.User
    belongs_to :user, Dfoto.Accounts.User

    has_one :thumbnail_for, Dfoto.Gallery.Album do
      destination_attribute :thumbnail_id
    end

    has_one :order, Dfoto.Gallery.OrderedImage do
      destination_attribute :id
    end
  end

  calculations do
    calculate :photographer_name,
              :string,
              expr(photographer_guest_name || photographer.name || "Unknown")

    calculate :extension, :string, {Dfoto.Calculations.FileExt, [key: :filename]}
  end
  """
end

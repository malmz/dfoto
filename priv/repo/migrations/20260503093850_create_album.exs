defmodule Dfoto.Repo.Migrations.CreateAlbum do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :title, :text, null: false
      add :description, :text, null: false
      add :status, :text, null: false, default: "draft"
      add :start_at, :utc_datetime, null: false, default: fragment("now()")
      add :version, :integer, null: false, default: 1

      timestamps()
    end

    create table(:images) do
      add :filename, :text, null: false
      add :photographer_guest_name, :text
      add :taken_at, :utc_datetime, default: fragment("now()")
      add :version, :integer, null: false, default: 1

      add :album_id, references(:albums), null: false
      add :user_id, references(:users, type: :uuid), null: false
      add :photographer_id, references(:users, type: :uuid)

      timestamps()
    end

    alter table(:albums) do
      add :thumbnail_id, references(:images)
    end
  end
end

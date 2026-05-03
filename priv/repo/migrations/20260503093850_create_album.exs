defmodule DFoto.Repo.Migrations.CreateAlbum do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :title, :text, null: false
      add :description, :text, null: false
      add :status, :text, null: false, default: "draft"
      add :start_at, :utc_datetime, null: false, default: fragment("now()")
      add :version, :integer, null: false, default: 1
      add :thumbnail_id, references(:images)

      timestamps()
    end
  end
end

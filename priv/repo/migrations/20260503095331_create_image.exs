defmodule DFoto.Repo.Migrations.CreateImage do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :filename, :text, null: false
      add :photographer_guest_name, :text
      add :taken_at, :utc_datetime, default: fragment("now()")
      add :version, :integer, null: false, default: 1

      add :album_id, references(:albums), null: false
      add :user_id, references(:users), null: false
      add :photographer_id, references(:users)

      timestamps()
    end
  end
end

defmodule Dfoto.Repo.Migrations.AddLegacyAlbums do
  use Ecto.Migration

  def change do
    create table(:legacy_albums, primary_key: false) do
      add :legacy_id, :text, null: false
      add :album_id, references(:albums), primary_key: true
    end
  end
end

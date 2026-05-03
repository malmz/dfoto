defmodule DFoto.Repo.Migrations.AddLegacyImages do
  use Ecto.Migration

  def change do
    create table(:legacy_images, primary_key: false) do
      add :legacy_id, :text, null: false
      add :image_id, references(:images), primary_key: true
    end
  end
end

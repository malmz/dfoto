defmodule Dfoto.Repo.Migrations.AddImageExtraView do
  use Ecto.Migration

  def up do
    execute """
    CREATE VIEW ordered_images AS (
      SELECT id, LAG(id) OVER w AS prev_id, LEAD(id) OVER w AS next_id FROM images
      WINDOW w AS (PARTITION BY album_id ORDER BY taken_at)
    );
    """
  end

  def down do
    execute """
    DROP VIEW ordered_images
    """
  end
end

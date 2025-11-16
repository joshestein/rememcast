defmodule Rememcast.Repo.Migrations.CreatePodcasts do
  use Ecto.Migration

  def change do
    create table(:podcasts) do
      add :title, :string
      add :artwork, :string
      add :podcast_index_id, :integer
      add :description, :text
      add :url, :string
      add :author, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:podcasts, [:podcast_index_id])
  end
end

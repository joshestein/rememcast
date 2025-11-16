defmodule Rememcast.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :title, :string
      add :description, :text
      add :publish_date, :utc_datetime
      add :duration, :integer
      add :audio_url, :string
      add :guid, :string
      add :episode_number, :integer
      add :podcast_id, references(:podcasts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:episodes, [:podcast_id])
  end
end

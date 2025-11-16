defmodule Rememcast.Content.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "episodes" do
    field :title, :string
    field :description, :string
    field :publish_date, :utc_datetime
    field :duration, :integer
    field :audio_url, :string
    field :guid, :string
    field :episode_number, :integer

    belongs_to :podcast, Rememcast.Content.Podcast

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [
      :title,
      :description,
      :publish_date,
      :duration,
      :audio_url,
      :guid,
      :episode_number
    ])
    |> validate_required([
      :title,
      :description,
      :publish_date,
      :duration,
      :audio_url,
      :guid,
      :episode_number
    ])
  end
end

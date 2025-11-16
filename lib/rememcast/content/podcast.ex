defmodule Rememcast.Content.Podcast do
  use Ecto.Schema
  import Ecto.Changeset

  schema "podcasts" do
    field :title, :string
    field :image_url, :string
    field :podcast_index_id, :integer
    field :description, :string
    field :url, :string
    field :author, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(podcast, attrs) do
    podcast
    |> cast(attrs, [:title, :image_url, :podcast_index_id, :description, :url, :author])
    |> validate_required([:title, :image_url, :podcast_index_id, :description, :url, :author])
    |> unique_constraint(:podcast_index_id)
  end
end

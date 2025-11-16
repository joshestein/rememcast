defmodule Rememcast.Content.Podcast do
  use Ecto.Schema
  import Ecto.Changeset

  schema "podcasts" do
    field :title, :string
    field :artwork, :string
    field :guid, :string
    field :description, :string
    field :url, :string
    field :author, :string

    has_many :episodes, Rememcast.Content.Episode

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(podcast, attrs) do
    podcast
    |> cast(attrs, [:title, :artwork, :guid, :description, :url, :author])
    |> validate_required([:title, :artwork, :guid, :description, :url, :author])
    |> unique_constraint(:guid)
  end
end

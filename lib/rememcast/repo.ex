defmodule Rememcast.Repo do
  use Ecto.Repo,
    otp_app: :rememcast,
    adapter: Ecto.Adapters.Postgres
end

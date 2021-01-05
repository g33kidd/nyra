defmodule Nyra.Repo do
  use Ecto.Repo,
    otp_app: :nyra,
    adapter: Ecto.Adapters.Postgres
end

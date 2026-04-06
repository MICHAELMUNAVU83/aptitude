defmodule Aptitude.Repo do
  use Ecto.Repo,
    otp_app: :aptitude,
    adapter: Ecto.Adapters.Postgres
end

defmodule GoogleSheets.Repo do
  use Ecto.Repo,
    otp_app: :google_sheets,
    adapter: Ecto.Adapters.Postgres
end

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :google_sheets,
  ecto_repos: [GoogleSheets.Repo]

# Configures the endpoint
config :google_sheets, GoogleSheetsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "peD3MWOHa1EmAAQIRLMgerSXHhu6+Ov5XTv04v84u4iVx2VHSsGytLiL2KKxEXnl",
  render_errors: [view: GoogleSheetsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GoogleSheets.PubSub,
  live_view: [signing_salt: "YlYDZflm"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Secrets to use Google API
config :google_sheets, :api_secrets,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  client_state: System.get_env("GOOGLE_CLIENT_STATE"),
  redirect_uri: System.get_env("GOOGLE_CONSENT_REDIRECT_URI"),
  default_permission_email: System.get_env("DEFAULT_PERMISSION_EMAIL")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

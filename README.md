### GoogleSheets
This repository was done to go along with [this](https://www.coletiv.com) article.

Google API and Google Sheets API Example Integration

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`
  * If you need to run in debug mode run `iex -S mix phx.server`

### To run the app
- Get your OAuth2.0 credentials for the Google Console (don't forget to activate Google Drive API and Google Sheets API in your project)
- Env vars to declare:
`GOOGLE_CLIENT_ID={your_google_client_id}`
`GOOGLE_CLIENT_SECRET={your_google_client_secret}`
`GOOGLE_CONSENT_REDIRECT_URI={your_server_host}/api/consent`
`GOOGLE_CLIENT_STATE={Generate a random secret to validate if the outside requests are coming from Google}`
`DEFAULT_PERMISSION_EMAIL={The google email drive account where you want to receive the created spreadsheet}`
- After setting all the environment variables and sourcing them, call the function `GoogleSheets.Requests.create_spreadsheet("YOUR_SPREADSHEET_NAME")` (run server in debug mode)
If you are prompted for a consent url, click on it and allow the permissions. You can change the permissions in the `scope` of `auth.ex` file.
If you are prompted with a `{:ok, SPREADSHEET_ID}` go to the google drive of the `DEFAULT_PERMISSION_EMAIL` and you'll find the newly generated sheet there!

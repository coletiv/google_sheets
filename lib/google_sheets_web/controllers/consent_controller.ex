defmodule GoogleSheetsWeb.ConsentController do
  use GoogleSheetsWeb, :controller

  alias GoogleSheets.Auth

  def consent(conn, %{"code" => code, "state" => state}) do
    my_state = Application.get_env(:google_sheets, :api_secrets)[:client_state]

    with true <- state == my_state,
         {:ok, :token_saved} <- Auth.save_tokens(code) do
      conn
      |> put_status(200)
      |> render("consent.json")
    else
      _ ->
        conn
        |> put_status(404)
        |> render("error.json")
    end
  end
end

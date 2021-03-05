defmodule GoogleSheets.Requests do
  @moduledoc """
  Module resposible for the communication between
  Sheets API and our application.
  """

  alias GoogleSheets.{Auth, Builder}

  @sheets_api_base_url "https://sheets.googleapis.com/v4/"
  @drive_api_base_url "https://www.googleapis.com/drive/v3/"
  @json_accept {"Accept", "application/json"}
  @json_content_type {"Content-Type", "application/json"}
  @request_timeout_high 10_000

  @doc """
  Creates a new spreadsheet with the title `sheet_name`.
  Also read & write permissions will be given to the
  default_permission_email()
  """
  def create_spreadsheet(sheet_name) do
    with {:ok, access_token} <- Auth.get_access_token(),
         {:ok, %HTTPoison.Response{body: body, status_code: 200}} <-
           HTTPoison.post(
             build_url(:create_spreadsheet, nil),
             json(:create_spreadsheet, sheet_name),
             [
               @json_content_type,
               @json_accept,
               {"Authorization", "#{access_token}"}
             ]
           ),
         {:ok, %{"spreadsheetId" => spreadsheet_id}} <- Poison.decode(body),
         {:ok, :permissions_success} <- access_spreadsheet(access_token, spreadsheet_id) do
      {:ok, spreadsheet_id}
    end
  end

  defp access_spreadsheet(access_token, spreadsheet_id, email \\ default_permission_email()) do
    with {:ok, %HTTPoison.Response{body: body, status_code: 200}} <-
           HTTPoison.post(
             build_url(:permissions, spreadsheet_id),
             json(:permissions, email),
             [
               @json_content_type,
               @json_accept,
               {"Authorization", "#{access_token}"}
             ],
             timeout: @request_timeout_high,
             recv_timeout: @request_timeout_high
           ),
         {:ok, %{"kind" => "drive#permission"}} <- Poison.decode(body) do
      {:ok, :permissions_success}
    else
      _ ->
        {:error, :permissions_fail}
    end
  end

  # Functions to build urls to make Google Sheets API calls
  defp build_url(:create_spreadsheet, _), do: @sheets_api_base_url <> "spreadsheets"

  defp build_url(:permissions, spreadsheet_id),
    do: @drive_api_base_url <> "files/" <> spreadsheet_id <> "/permissions"

  # Functions to create the body of the Google API Request calls
  defp json(:create_spreadsheet, project_name) do
    Builder.build(:create, project_name)
    |> Poison.encode!()
  end

  defp json(:permissions, email) do
    %{
      emailAddress: email,
      role: "writer",
      type: "user"
    }
    |> Poison.encode!()
  end

  # Functions to get environment variables
  defp default_permission_email,
    do: Application.get_env(:google_sheets, :api_secrets)[:default_permission_email]
end

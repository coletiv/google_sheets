defmodule GoogleSheets.Auth do
  @moduledoc """
  This module will handle all the work of creating and saving new tokens
  into our application.
  """

  alias GoogleSheets.Dets

  @oauth_code_base_uri "https://accounts.google.com/o/oauth2/v2/auth"
  @oauth_token_base_uri "https://oauth2.googleapis.com/"
  @scope "https://www.googleapis.com/auth/drive"

  @doc """
  Returns the access token used to make google api calls.
  """
  def get_access_token do
    saved_tokens = Dets.get_google()

    with false <- Blankable.blank?(saved_tokens.access_expire_time),
         false <- Timex.now() > saved_tokens.access_expire_time,
         false <- Blankable.blank?(saved_tokens.access_token) do
      {:ok, "Bearer #{saved_tokens.access_token}"}
    else
      true ->
        case Blankable.blank?(saved_tokens.refresh_token) do
          false -> get_access_from_refresh_token(saved_tokens.refresh_token)
          true -> consent_error()
        end
    end
  end

  defp get_access_from_refresh_token(refresh_token) do
    url = build_url(:refresh_token, refresh_token)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(url, "", [{"Content-Type", "application/x-www-form-urlencoded"}]),
         {:ok, decoded_body} <- Poison.decode(body),
         {:ok, _dets_values} <-
           Dets.upsert_dets_values(%{
             google_access_token: decoded_body["access_token"],
             google_access_expire_time:
               Timex.shift(Timex.now(), seconds: decoded_body["expires_in"])
           }) do
      {:ok, "Bearer #{decoded_body["access_token"]}"}
    else
      _ -> {:error, :request_error}
    end
  end

  @doc """
  Called when application is consented to backercamp. It makes a google api call
  to generate a new refresh and access token. Saves both tokens plus the access
  expire time onto our admin_settings.
  """
  def save_tokens(code) do
    url = build_url(:generate_token, code)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(url, "", [{"Content-Type", "application/x-www-form-urlencoded"}]),
         {:ok, decoded_body} <- Poison.decode(body),
         {:ok, _dets_values} <-
           Dets.upsert_dets_values(%{
             google_refresh_token: decoded_body["refresh_token"],
             google_access_token: decoded_body["access_token"],
             google_access_expire_time:
               Timex.shift(Timex.now(), seconds: decoded_body["expires_in"])
           }) do
      {:ok, :token_saved}
    else
      _ -> {:error, :request_error}
    end
  end

  defp consent_error,
    do:
      {:error,
       %{
         message: "Consent google_sheets app to access google api.",
         url: build_url(:consent_url, nil)
       }}

  # Functions to build google api urls for generating consent url and access_tokens
  defp build_url(:generate_token, code),
    do:
      "#{@oauth_token_base_uri}token?code=#{code}&client_id=#{client_id()}&client_secret=#{
        client_secret()
      }&redirect_uri=#{redirect_uri()}&grant_type=authorization_code"

  defp build_url(:refresh_token, refresh_token),
    do:
      "#{@oauth_token_base_uri}token?refresh_token=#{refresh_token}&client_id=#{client_id()}&client_secret=#{
        client_secret()
      }&grant_type=refresh_token"

  defp build_url(:consent_url, _),
    do:
      "#{@oauth_code_base_uri}?client_id=#{client_id()}&redirect_uri=#{redirect_uri()}&response_type=code&scope=#{
        @scope
      }&state=#{state()}&access_type=offline"

  # Functions to get environmental variables
  defp client_id(), do: Application.get_env(:google_sheets, :api_secrets)[:client_id]
  defp client_secret(), do: Application.get_env(:google_sheets, :api_secrets)[:client_secret]
  defp state(), do: Application.get_env(:google_sheets, :api_secrets)[:client_state]
  defp redirect_uri(), do: Application.get_env(:google_sheets, :api_secrets)[:redirect_uri]
end

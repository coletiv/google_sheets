defmodule GoogleSheets.Dets do
  @moduledoc """
  This module is used to create dets file
  Store and get values from dets file
  Do not forget to create on the root of the project
  the file with name @dets_file_name.
  """

  alias GoogleSheets.Dets

  @dets_file_name 'dets'

  defstruct google_refresh_token: nil,
            google_access_token: nil,
            google_access_expire_time: nil

  @doc """
  Gets the variables of the dets file that are used
  to make Google API calls.
  """
  def get_google do
    {:ok, dets_values} = get_dets_values()

    %{
      refresh_token: Map.get(dets_values, :google_refresh_token, ""),
      access_token: Map.get(dets_values, :google_access_token, ""),
      access_expire_time: Map.get(dets_values, :google_access_expire_time, "")
    }
  end

  @doc """
  Gets dets values (using dets from erlang)
  """
  def get_dets_values do
    with {:ok, dets_values_table} <- open_and_get_dets_values_table() do
      dets_values =
        case :dets.lookup(
               dets_values_table,
               @dets_file_name
             ) do
          [] ->
            :dets.insert(
              dets_values_table,
              {@dets_file_name, %Dets{}}
            )

            %Dets{}

          [{_, dets_value} | _] ->
            Map.merge(%Dets{}, dets_value)
        end

      :dets.close(dets_values_table)
      {:ok, dets_values}
    end
  end

  @doc """
  Inserts or updates dets values on dets file
  """
  def upsert_dets_values(params) do
    with {:ok, dets_values} <- get_dets_values(),
         {:ok, dets_values_table} <- open_and_get_dets_values_table() do
      dets_values = Map.merge(dets_values, params)

      google_refresh_token =
        case !Blankable.blank?(Map.get(dets_values, :google_refresh_token)) do
          true ->
            dets_values.google_refresh_token

          false ->
            Map.get(get_google(), :google_refresh_token, "")
        end

      dets_values =
        Map.merge(
          %Dets{},
          Map.put(
            dets_values,
            :google_refresh_token,
            google_refresh_token
          )
        )

      google_access_token =
        case !Blankable.blank?(Map.get(dets_values, :google_access_token)) do
          true ->
            dets_values.google_access_token

          false ->
            Map.get(get_google(), :access_token, "")
        end

      dets_values =
        Map.merge(
          %Dets{},
          Map.put(
            dets_values,
            :google_access_token,
            google_access_token
          )
        )

      google_access_expire_time =
        case !Blankable.blank?(Map.get(dets_values, :google_access_expire_time)) do
          true ->
            dets_values.google_access_expire_time

          false ->
            Map.get(get_google(), :access_expire_time, nil)
        end

      dets_values =
        Map.merge(
          %Dets{},
          Map.put(
            dets_values,
            :google_access_expire_time,
            google_access_expire_time
          )
        )

      :dets.insert(
        dets_values_table,
        {@dets_file_name, dets_values}
      )

      :dets.close(dets_values_table)
      {:ok, dets_values}
    end
  end

  defp open_and_get_dets_values_table, do: :dets.open_file(:dets, type: :set)
end

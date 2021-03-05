defmodule GoogleSheetsWeb.ConsentView do
  use GoogleSheetsWeb, :view

  def render("consent.json", _) do
    %{info: "Consent received with success!"}
  end

  def render("error.json", _) do
    %{info: "Error completing the request!"}
  end
end

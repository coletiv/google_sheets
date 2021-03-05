defmodule GoogleSheetsWeb.PageController do
  use GoogleSheetsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

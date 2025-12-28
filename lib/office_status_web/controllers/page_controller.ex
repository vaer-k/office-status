defmodule OfficeStatusWeb.PageController do
  use OfficeStatusWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

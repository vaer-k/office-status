defmodule OfficeStatusWeb.StatusController do
  use OfficeStatusWeb, :controller

  alias OfficeStatus.Statuses

  @doc """
  Returns the current active status as JSON.
  This endpoint is designed for TRMNL displays to fetch the current status.
  """
  def show(conn, _params) do
    case Statuses.get_active_status() do
      nil ->
        json(conn, %{
          status: "unknown",
          name: "No Status",
          message: "No status has been set",
          icon: "❓",
          color: "gray"
        })

      status ->
        json(conn, %{
          status: "ok",
          name: status.name,
          message: status.message,
          icon: status.icon,
          color: status.color,
          updated_at: status.updated_at
        })
    end
  end
end

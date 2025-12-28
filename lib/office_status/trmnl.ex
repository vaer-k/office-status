defmodule OfficeStatus.TRMNL do
  @moduledoc """
  Client for posting status updates to TRMNL display API using Finch.
  """

  require Logger

  @trmnl_url "https://usetrmnl.com/api/custom_plugins/1dfa3059-dceb-451b-a402-68c9efbde6ca"

  @doc """
  Posts a status update to the TRMNL API.

  Accepts either a Status struct or just the status name.
  Sends all status fields as merge_variables for the TRMNL template.
  """
  def update_status(%OfficeStatus.Statuses.Status{} = status) do
    body =
      Jason.encode!(%{
        merge_variables: %{
          name: status.name,
          message: status.message,
          icon: status.icon,
          color: status.color
        }
      })

    send_request(body, status.name)
  end

  def update_status(status_name) when is_binary(status_name) do
    # Fallback for just a status name (backwards compatibility)
    body =
      Jason.encode!(%{
        merge_variables: %{
          name: status_name,
          message: "",
          icon: "",
          color: ""
        }
      })

    send_request(body, status_name)
  end

  defp send_request(body, status_name) do
    request =
      Finch.build(
        :post,
        @trmnl_url,
        [{"content-type", "application/json"}],
        body
      )

    case Finch.request(request, OfficeStatus.Finch) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("TRMNL updated successfully: #{status_name}")
        :ok

      {:ok, %{status: status, body: response_body}} ->
        Logger.error("TRMNL update failed with status #{status}: #{response_body}")
        {:error, :api_error}

      {:error, reason} ->
        Logger.error("TRMNL update failed: #{inspect(reason)}")
        {:error, reason}
    end
  end
end

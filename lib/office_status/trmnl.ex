defmodule OfficeStatus.TRMNL do
  @moduledoc """
  Client for posting status updates to TRMNL display API using Finch.
  """

  require Logger

  @trmnl_url "https://usetrmnl.com/api/custom_plugins/1dfa3059-dceb-451b-a402-68c9efbde6ca"

  @doc """
  Posts a status update to the TRMNL API.

  The status will be displayed on TRMNL devices.
  If the status is "Available", the time is left empty.
  Otherwise, the current Pacific time is included.
  """
  def update_status(status_name) do
    # Format status name for display (uppercase)
    display_status = String.upcase(status_name)

    # Format the current time for the footer (Pacific time)
    current_time = format_pacific_time()

    body =
      Jason.encode!(%{
        merge_variables: %{
          status: display_status,
          time: if(display_status == "AVAILABLE", do: "", else: current_time)
        }
      })

    request =
      Finch.build(
        :post,
        @trmnl_url,
        [{"content-type", "application/json"}],
        body
      )

    case Finch.request(request, OfficeStatus.Finch) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("TRMNL updated successfully: #{display_status}")
        :ok

      {:ok, %{status: status, body: response_body}} ->
        Logger.error("TRMNL update failed with status #{status}: #{response_body}")
        {:error, :api_error}

      {:error, reason} ->
        Logger.error("TRMNL update failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp format_pacific_time do
    {:ok, now} = DateTime.now("America/Los_Angeles")
    Calendar.strftime(now, "%I:%M %p")
  end
end

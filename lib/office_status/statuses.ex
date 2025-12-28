defmodule OfficeStatus.Statuses do
  @moduledoc """
  The Statuses context for managing office availability status.
  """

  import Ecto.Query, warn: false
  alias OfficeStatus.Repo
  alias OfficeStatus.Statuses.Status

  @doc """
  Returns all statuses ordered by display_order.
  """
  def list_statuses do
    Status
    |> order_by(:display_order)
    |> Repo.all()
  end

  @doc """
  Gets a single status by ID.
  """
  def get_status!(id), do: Repo.get!(Status, id)

  @doc """
  Gets the currently active status.
  """
  def get_active_status do
    Status
    |> where([s], s.is_active == true)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Sets a status as active, deactivating all others.
  Accepts either a Status struct or an ID.
  """
  def set_active_status(status_or_id)

  def set_active_status(%Status{} = status) do
    Repo.transaction(fn ->
      # Deactivate all statuses
      from(s in Status, where: s.is_active == true)
      |> Repo.update_all(set: [is_active: false, updated_at: DateTime.utc_now()])

      # Activate the selected status
      status
      |> Status.changeset(%{is_active: true})
      |> Repo.update!()
    end)
    |> case do
      {:ok, updated_status} ->
        # Broadcast the status change
        Phoenix.PubSub.broadcast(
          OfficeStatus.PubSub,
          "status:updates",
          {:status_changed, updated_status}
        )

        # Post status update to TRMNL (async to not block response)
        Task.start(fn -> OfficeStatus.TRMNL.update_status(updated_status) end)

        {:ok, updated_status}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def set_active_status(id) when is_integer(id) or is_binary(id) do
    get_status!(id)
    |> set_active_status()
  end

  @doc """
  Updates the custom message for a status.
  """
  def update_status_message(%Status{} = status, message) do
    status
    |> Status.changeset(%{message: message})
    |> Repo.update()
    |> case do
      {:ok, updated_status} ->
        if updated_status.is_active do
          Phoenix.PubSub.broadcast(
            OfficeStatus.PubSub,
            "status:updates",
            {:status_changed, updated_status}
          )
        end

        {:ok, updated_status}

      error ->
        error
    end
  end

  @doc """
  Creates a new status.
  """
  def create_status(attrs \\ %{}) do
    %Status{}
    |> Status.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a status.
  """
  def update_status(%Status{} = status, attrs) do
    status
    |> Status.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a status.
  """
  def delete_status(%Status{} = status) do
    Repo.delete(status)
  end

  @doc """
  Returns a changeset for tracking status changes.
  """
  def change_status(%Status{} = status, attrs \\ %{}) do
    Status.changeset(status, attrs)
  end
end

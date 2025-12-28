defmodule OfficeStatusWeb.DashboardLive do
  use OfficeStatusWeb, :live_view

  alias OfficeStatus.Statuses

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(OfficeStatus.PubSub, "status:updates")
    end

    statuses = Statuses.list_statuses()
    active_status = Statuses.get_active_status()

    {:ok,
     socket
     |> assign(:statuses, statuses)
     |> assign(:active_status, active_status)
     |> assign(:editing_message, false)
     |> assign(
       :message_form,
       to_form(%{"message" => (active_status && active_status.message) || ""})
     )}
  end

  @impl true
  def handle_event("set_status", %{"id" => id}, socket) do
    case Statuses.set_active_status(id) do
      {:ok, status} ->
        {:noreply,
         socket
         |> assign(:active_status, status)
         |> assign(:statuses, Statuses.list_statuses())
         |> assign(:message_form, to_form(%{"message" => status.message}))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update status")}
    end
  end

  def handle_event("toggle_message_edit", _, socket) do
    {:noreply, assign(socket, :editing_message, !socket.assigns.editing_message)}
  end

  def handle_event("update_message", %{"message" => message}, socket) do
    case socket.assigns.active_status do
      nil ->
        {:noreply, socket}

      status ->
        case Statuses.update_status_message(status, message) do
          {:ok, updated_status} ->
            {:noreply,
             socket
             |> assign(:active_status, updated_status)
             |> assign(:statuses, Statuses.list_statuses())
             |> assign(:editing_message, false)
             |> assign(:message_form, to_form(%{"message" => updated_status.message}))}

          {:error, _reason} ->
            {:noreply, put_flash(socket, :error, "Failed to update message")}
        end
    end
  end

  @impl true
  def handle_info({:status_changed, status}, socket) do
    {:noreply,
     socket
     |> assign(:active_status, status)
     |> assign(:statuses, Statuses.list_statuses())
     |> assign(:message_form, to_form(%{"message" => status.message}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="dashboard">
      <!-- Current Status Hero -->
      <div class={"status-hero status-hero--#{@active_status && @active_status.color || "gray"}"}>
        <div class="status-hero__icon">
          {if @active_status, do: @active_status.icon, else: "❓"}
        </div>
        <div class="status-hero__content">
          <h1 class="status-hero__name">
            {if @active_status, do: @active_status.name, else: "No Status Set"}
          </h1>

          <%= if @editing_message and @active_status do %>
            <form phx-submit="update_message" class="message-edit-form">
              <input
                type="text"
                name="message"
                value={@active_status.message}
                class="message-input"
                placeholder="Enter a custom message..."
                autofocus
              />
              <div class="message-edit-actions">
                <button type="submit" class="btn btn--save">Save</button>
                <button type="button" phx-click="toggle_message_edit" class="btn btn--cancel">
                  Cancel
                </button>
              </div>
            </form>
          <% else %>
            <p class="status-hero__message" phx-click="toggle_message_edit" title="Click to edit">
              {if @active_status, do: @active_status.message, else: "Select a status below"}
              <span class="edit-hint">✏️</span>
            </p>
          <% end %>
        </div>
      </div>
      
    <!-- Status Buttons Grid -->
      <div class="status-grid">
        <%= for status <- @statuses do %>
          <button
            phx-click="set_status"
            phx-value-id={status.id}
            class={"status-card status-card--#{status.color} #{if status.is_active, do: "status-card--active", else: ""}"}
          >
            <span class="status-card__icon">{status.icon}</span>
            <span class="status-card__name">{status.name}</span>
            <%= if status.is_active do %>
              <span class="status-card__badge">Active</span>
            <% end %>
          </button>
        <% end %>
      </div>
      
    <!-- Footer Info -->
      <div class="dashboard-footer">
        <p>TRMNL displays will update automatically when you change your status.</p>
        <p class="api-hint">API: <code>/api/status</code></p>
      </div>
    </div>
    """
  end
end

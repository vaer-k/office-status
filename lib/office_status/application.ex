defmodule OfficeStatus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OfficeStatusWeb.Telemetry,
      OfficeStatus.Repo,
      {DNSCluster, query: Application.get_env(:office_status, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OfficeStatus.PubSub},
      # Start a worker by calling: OfficeStatus.Worker.start_link(arg)
      # {OfficeStatus.Worker, arg},
      # Start to serve requests, typically the last entry
      OfficeStatusWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OfficeStatus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OfficeStatusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

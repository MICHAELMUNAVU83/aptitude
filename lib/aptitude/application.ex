defmodule Aptitude.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AptitudeWeb.Telemetry,
      Aptitude.Repo,
      {DNSCluster, query: Application.get_env(:aptitude, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Aptitude.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Aptitude.Finch},
      # Start a worker by calling: Aptitude.Worker.start_link(arg)
      # {Aptitude.Worker, arg},
      # Start to serve requests, typically the last entry
      AptitudeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aptitude.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AptitudeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

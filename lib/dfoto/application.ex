defmodule DFoto.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Oidcc.ProviderConfiguration.Worker,
       %{
         name: DFoto.AuthentikOidcProvider,
         issuer: Application.fetch_env!(:dfoto, :authentik)[:issuer]
       }},
      DFotoWeb.Telemetry,
      DFoto.Repo,
      {DNSCluster, query: Application.get_env(:dfoto, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DFoto.PubSub},
      # Start a worker by calling: DFoto.Worker.start_link(arg)
      # {DFoto.Worker, arg},
      # Start to serve requests, typically the last entry
      DFotoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DFoto.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DFotoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Dfoto.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Oidcc.ProviderConfiguration.Worker,
       %{
         name: Dfoto.OidccConfigProvider,
         issuer: Application.fetch_env!(:dfoto, Dfoto.OidccConfigProvider)[:issuer]
       }},
      DfotoWeb.Telemetry,
      Dfoto.Repo,
      {DNSCluster, query: Application.get_env(:dfoto, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dfoto.PubSub},
      # Start a worker by calling: Dfoto.Worker.start_link(arg)
      # {Dfoto.Worker, arg},
      # Start to serve requests, typically the last entry
      DfotoWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :dfoto]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dfoto.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DfotoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

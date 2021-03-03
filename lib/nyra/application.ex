defmodule Nyra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  use Application

  # Start a worker by calling: Nyra.Worker.start_link(arg)
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Nyra.Repo,
      # Start the Telemetry supervisor
      NyraWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Nyra.PubSub},
      # Start Presence Monitor
      # Nyra.Messaging.Monitor,
      # Start the Endpoint (http/https)
      NyraWeb.Endpoint,
      # Start Phoenix Presence
      NyraWeb.Presence,
      # Start Messaging Service
      Nyra.Messaging,
      # Start the User Pool
      Nyra.UserPool,
      # Plug Attack storage
      {PlugAttack.Storage.Ets, name: Nyra.PlugAttack.Storage, clean_period: 60_000}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nyra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NyraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Nyra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Nyra.Repo,
      # Start the Telemetry supervisor
      NyraWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Nyra.PubSub},
      # Start the Endpoint (http/https)
      NyraWeb.Endpoint,
      # Start a worker by calling: Nyra.Worker.start_link(arg)
      # {Nyra.Worker, arg}
      # Nyra.Bouncer
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

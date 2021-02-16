defmodule NyraWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :nyra,
    pubsub_server: Nyra.PubSub

  def track_user(pid, socket, data) do
    track(pid, "lobby", socket.id, data)
  end

  def list_online(), do: list("lobby")

  # def exists?([], nil), do: {:}
  def exists?(devices, id) when is_binary(id) when is_map(devices) do
    case Map.get(devices, id) do
      nil -> false
      %{} -> true
    end
  end

  def handle_info(c, d) do
    IO.inspect(c)
    d
  end
end

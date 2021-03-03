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

  @doc "List online users for a topic"
  def list_online(topic \\ "lobby"), do: list(topic)

  @doc "Get the count of all active users on a topic"
  def count_online(topic \\ "lobby") do
    topic
    |> list()
    |> Enum.count()
  end

  # TODO more information here + cached values in ETS or similar service.
  @doc "Get some stats about users and information in Presence"
  def statistics(topic \\ "lobby") do
    %{
      online: count_online(topic)
    }
  end
end

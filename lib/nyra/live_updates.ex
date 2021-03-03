defmodule Nyra.LiveUpdates do
  # I don't know what this is for...
  @topic inspect(__MODULE__)

  @doc "subscribes for everyone"
  def subscribe_live_view() do
    Phoenix.PubSub.subscribe(Nyra.PubSub, topic(), link: true)
  end

  @doc "subscribes a specific user"
  def subscribe_live_view(pid, socket, uuid) do
    Phoenix.PubSub.subscribe(Nyra.PubSub, topic(uuid), link: true)

    NyraWeb.Presence.track(pid, "lobby", socket.id, %{
      id: uuid,
      online_at: :os.system_time(:seconds)
    })
  end

  @doc "notify all users"
  def notify_live_view(payload) do
    Phoenix.PubSub.broadcast(Nyra.PubSub, topic(), payload)
  end

  @doc "notify a specific user"
  def notify_live_view(uuid, payload) do
    Phoenix.PubSub.broadcast(Nyra.PubSub, topic(uuid), payload)
  end

  defp topic, do: @topic
  defp topic(id), do: topic() <> to_string(id)
end

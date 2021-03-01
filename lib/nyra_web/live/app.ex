defmodule NyraWeb.AppLive do
  use NyraWeb, :live_view

  alias Nyra.Accounts
  alias NyraWeb.{Components, Presence, Endpoint}
  alias Phoenix.Socket.Broadcast

  import NyraWeb.Helpers

  @assign_defaults [
    current_user: nil,
    online_users_count: "???",
    content: nil,
    loading: true,
    error: ""
  ]

  @impl true
  def render(assigns) do
    ~L"""
    <div class="inner">
      <%= live_component(@socket, Components.StatusBar, [
        id: "status_bar",
        current_user: @current_user,
        online: @online_users_count
      ]) %>

      <%= live_component(@socket, Components.Chat, [
        id: "chat",
        current_user: @current_user,
        content: @content,
        online: @online_users_count
      ]) %>

      <%= live_component(@socket, Components.ChatComposer, [
        id: "composer",
        current_user: @current_user,
        content: @content,
        online: @online_users_count
      ]) %>
    </div>
    """
  end

  @impl true
  # TODO figure out how to tell if a socket has been Disconnected!
  # remove the user from the UserPool when they're Disconnected
  def mount(_params, %{"token" => token}, socket) do
    socket = assign(socket, @assign_defaults)

    with true <- connected?(socket),
         {:ok, uuid} <- verify_token(socket, "user token", token),
         :ok <- Accounts.is_activated?(uuid),
         user <- Accounts.take(uuid, [:id, :username]) do
      Endpoint.subscribe("lobby")

      Presence.track(self(), "lobby", socket.id, %{
        id: uuid,
        online_at: :os.system_time(:seconds)
      })

      Nyra.LiveUpdates.subscribe_live_view(uuid)

      Nyra.UserPool.add(socket, uuid, [])

      new_assigns = [
        current_user: Map.from_struct(user),
        online_users_count: Presence.count_online(),
        loading: false
      ]

      {:ok, assign(socket, new_assigns), temporary_assigns: new_assigns}
    else
      false ->
        {:ok, socket}

      {:error, error} ->
        {:ok, assign(socket, error: error), temporary_assigns: [error: error]}
    end
  end

  # TODO handles payload.leaves && payload.joins
  # TODO setup a monitor for Presence to let other clients know when this one leaves.
  @impl true
  @doc "Handles Phoenix socket broadcasts from the presence channel."
  def handle_info(%Broadcast{event: "presence_diff", payload: %{joins: _joins, leaves: _leaves}}, socket) do
    {:noreply,
     socket
     |> assign(online_users_count: Presence.count_online())}
  end

  # TODO this needs to send to another client that's also connected to the same UserPool????
  @impl true
  def handle_info({:compose_message, content}, socket) do
    {:noreply, socket}
  end
end

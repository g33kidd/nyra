defmodule NyraWeb.AppLive do
  use NyraWeb, :live_view

  alias Nyra.Accounts
  alias NyraWeb.{Components, Presence, Endpoint}
  alias Phoenix.Socket.Broadcast

  import NyraWeb.Helpers
  import NyraWeb.Router.Helpers

  @assign_defaults [
    current_user: nil,
    online_users_count: "???",
    loading: true,
    error: ""
  ]

  @impl true
  def render(assigns) do
    ~L"""
    <%= live_component(@socket, Components.StatusBar, [
      id: "status_bar",
      current_user: @current_user,
      online: @online_users_count
    ]) %>
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

  @impl true
  @doc """
  Handles Phoenix socket broadcasts from the presence channel.

    1. Updates the current online users count.
    2. Removes the user that just disconnected from the ENTIRE pool of users.

    # TODO handles payload.leaves && payload.joins
    # !NOTE this is only called when the user joins.

  """
  def handle_info(%Broadcast{event: "presence_diff", payload: %{joins: _joins, leaves: _leaves}}, socket) do
    socket =
      assign(socket,
        online_users_count: Presence.count_online()
      )

    {:noreply, socket}
  end
end

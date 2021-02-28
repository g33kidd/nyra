defmodule NyraWeb.AppLive do
  @moduledoc """

  TODO ! hey this is important
  need to figure out a way to notify the UserPool w

  """

  use NyraWeb, :live_view

  alias Nyra.Accounts
  alias NyraWeb.{Components, Presence}

  import NyraWeb.Helpers
  import NyraWeb.Router.Helpers, only: [session_path: 2, page_path: 2]

  @assign_defaults [
    current_user: %{
      id: nil,
      username: nil
    },
    online_users_count: nil,
    loading: true,
    error: nil
  ]

  @impl true
  def render(assigns) do
    ~L"""
    <%= live_component(@socket, Components.StatusBar, id: "status_bar", loading: @loading, online_users_count: @online_users_count) %>

    <div>Loading: <%= @loading %></div>
    <div>Current User Count: <%= @current_user.username %></div>
    <div><%= @online_users_count %></div>
    """
  end

  @impl true
  @doc """

  1. Check if this request is actually a connected user.
  2. Ensure this user is using a single device using this email.
  3. Track the user in presence for pooling and online state type stuff.

  handle_err tries to determine the determine the cause of the error. If not, it will run the default method
  unresolved. It returns a modified socket with assigns or redirects.

  TODO instead of redirection to :index they should have their own pages.. too lazy rn.
  TODO figure out how to tell if a socket has been Disconnected!
    need this in order to remove the user from the UserPool when they're not on the site anymore.
  """
  def mount(_params, session, socket) do
    socket = assign(socket, @assign_defaults)

    with true <- connected?(socket),
         {:ok, uuid} <- is_user_session?(session),
         :ok <- ensure_single_device(uuid),
         :ok <- Accounts.is_activated?(uuid),
         user_info <- Accounts.take(uuid, [:id, :username]) do
      socket
      |> pool(uuid, [])
      |> track(uuid)
      |> assign(
        current_user: user_info,
        online_users_count: Presence.count_online(),
        loading: false
      )
    else
      false -> socket
      {:error, error} -> handle_error(socket, error)
    end

    {:ok, socket}
  end

  @doc "Handles error states by modifying the socket"
  def handle_error(socket, :no_token) do
    redirect(socket, to: session_path(socket, :destroy))
  end

  def handle_error(socket, :device_exists) do
    redirect(socket, to: session_path(socket, :destroy))
  end

  def handle_error(socket, :account_not_active) do
    redirect(socket, to: session_path(socket, :destroy))
  end

  def handle_error(socket, error) do
    socket
    |> assign(error: error)
    |> redirect(to: page_path(socket, :index))
  end

  @impl true
  @doc """
  Handles Phoenix socket broadcasts from the presence channel.

    1. Updates the current online users count.
    2. Removes the user that just disconnected from the ENTIRE pool of users.

    # TODO handles payload.leaves && payload.joins
    # !NOTE this is only called when the user joins.

  """
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: _payload
        },
        socket
      ) do
    socket =
      assign(socket,
        online_users_count: Presence.count_online()
      )

    {:noreply, socket}
  end
end

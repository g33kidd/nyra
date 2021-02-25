defmodule NyraWeb.AppLive do
  @moduledoc """

  TODO ! hey this is important
  need to figure out a way to notify the UserPool w

  """

  use NyraWeb, :live_view

  alias Nyra.{Accounts, UserPool}
  alias NyraWeb.{Router, Presence, Endpoint}

  import NyraWeb.Helpers

  defp assign_defaults(socket) do
    assign(socket,
      current_user: %{
        id: nil,
        username: nil
      },
      online_users_count: nil,
      loading: true,
      error: nil
    )
  end

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
  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket)

    socket =
      with true <- connected?(socket),
           {:ok, uuid} <- is_user_session?(session),
           :ok <- ensure_single_device(uuid),
           :ok <- Accounts.is_activated?(uuid) do
        # Subscribe to the lobby and track this session in Presence
        Endpoint.subscribe("lobby")

        Presence.track(
          self(),
          "lobby",
          socket.id,
          %{
            current_user: uuid,
            online_at: :os.system_time(:seconds)
          }
        )

        # Subscribe the user to the UserPool.
        UserPool.add_user(uuid)

        user_info = Accounts.take(uuid, [:id, :username])

        assigns = [
          current_user: user_info,
          online_users_count: Presence.count_online(),
          loading: false
        ]

        assign(socket, assigns)
      else
        {:error, :no_token} ->
          redirect(socket, to: Router.Helpers.session_path(socket, :destroy))

        {:error, :device_exists} ->
          IO.inspect("device already connected")
          redirect(socket, to: Router.Helpers.session_path(socket, :destroy))

        # This should be the only case in which there is some boolean value.
        # Other cases will be state information stored as a Tuple.
        # also, this relates to [connected?/1]
        false ->
          IO.inspect("Disconnected")
          socket

        {:error, :account_not_active} ->
          redirect(socket, to: Router.Helpers.session_path(socket, :destroy))

        {:error, default_error} ->
          assign(socket, error: default_error)
          redirect(socket, to: Router.Helpers.page_path(socket, :index))
      end

    {:ok, socket}
  end

  # Channel Messages

  # Phoenix Presence Stuff

  @doc """
  Handles Phoenix socket broadcasts from the presence channel.

    1. Updates the current online users count.
    2. Removes the user that just disconnected from the ENTIRE pool of users.
    3.

    # TODO handles payload.leaves && payload.joins

  """
  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _payload}, socket) do
    socket =
      assign(socket,
        online_users_count: Presence.count_online()
      )

    {:noreply, socket}
  end
end

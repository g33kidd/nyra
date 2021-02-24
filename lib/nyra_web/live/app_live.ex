defmodule NyraWeb.AppLive do
  use NyraWeb, :live_view

  alias Nyra.Accounts
  alias NyraWeb.{Router, Presence, Endpoint}

  import NyraWeb.Helpers

  @doc """

    1. Check if this request is actually a connected user.
    2. Ensure this user is using a single device using this email.
    3. Track the user in presence for pooling and online state type stuff.

  handle_err tries to determine the determine the cause of the error. If not, it will run the default method
  unresolved. It returns a modified socket with assigns or redirects.

  TODO instead of redirection to :index they should have their own pages.. too lazy rn.

  """
  @impl true
  def mount(_params, session, socket) do
    # Default assigns
    socket =
      socket
      |> assign(
        current_user: %{
          id: nil,
          username: nil
        },
        online_users_count: nil,
        loading: true,
        error: nil
      )

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

        presence_count =
          Presence.list_online()
          |> Enum.count()

        user_info = Map.take(Accounts.find(uuid), [:username, :id])

        assigns = [
          current_user: user_info,
          online_users_count: presence_count,
          loading: false
        ]

        assign(socket, assigns)
      else
        {:error, :no_token} ->
          redirect(socket, to: Router.Helpers.page_path(socket, :index))

        {:error, :device_exists} ->
          # TODO this should redirect to somewhere else.
          redirect(socket, to: Router.Helpers.page_path(socket, :index))

        # This should be the only case in which there is some boolean value.
        # Other cases will be state information stored as a Tuple.
        # also, this relates to [connected?/1]
        false ->
          socket

        {:error, :account_not_active} ->
          redirect(socket, to: Router.Helpers.page_path(socket, :index))

        {:error, default_error} ->
          assign(socket, error: default_error)
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

  """
  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _payload}, socket) do
    presence_count =
      Presence.list_online()
      |> Enum.count()

    # TODO handles payload.leaves && payload.joins
    # Just because we really need to remove the user that's leaving from everything.

    {:noreply, assign(socket, online_users_count: presence_count)}
  end
end

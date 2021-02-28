defmodule NyraWeb.AppLive do
  use NyraWeb, :live_view

  alias Nyra.Accounts
  alias NyraWeb.{Components, Presence}

  import NyraWeb.Helpers
  import NyraWeb.Router.Helpers

  @assign_defaults [
    username: "",
    user_id: "",
    current_user: nil,
    online_users_count: nil,
    loading: true,
    error: ""
  ]

  @impl true
  def render(assigns) do
    ~L"""
    <%= if @loading do %>
      <%= live_component(@socket, Components.Loading, id: "loading") %>
    <% else %>
      <%= live_component(@socket, Components.StatusBar, [
        id: "status_bar",
        current_user: @current_user,
        username: @username,
        user_id: @user_id,
        loading: @loading,
        online: @online_users_count
      ]) %>
    <% end %>
    """
  end

  @impl true
  def handle_event("token_restore", %{"token" => nil}, socket) do
    if connected?(socket) do
      {:noreply, redirect(socket, to: page_path(socket, :index))}
    end
  end

  @impl true
  def handle_event("token_restore", %{"token" => token}, socket) do
    socket =
      with {:ok, user_id} <- verify_token(socket, "user token", token),
           user <- Accounts.find(user_id) do
        assign(socket,
          current_user: Map.from_struct(user),
          loading: false
        )
      else
        {:error, :invalid} ->
          socket

        {:error, :expired} ->
          socket

        {:error, :missing} ->
          socket

        nil ->
          socket
      end

    {:noreply, socket}
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
  def mount(_params, _session, socket) do
    socket = assign(socket, @assign_defaults)

    socket =
      with true <- connected?(socket) do
        socket
        |> IO.inspect()
      else
        false -> socket
      end

    # if connected?(socket), do: Process.send_after(self(), :presence_info, 500)
    # if connected?(socket), do: Process.send_after(self(), :update, 500)

    # socket =
    #   with true <- connected?(socket),
    #     :ok <- ensure_single_device(uuid)
    #    do
    #     # assign(socket, loading: false)
    #   else
    #     false -> socket
    #     {:error, :no_token} -> socket
    #   end

    {:ok, socket}

    # socket =
    #   with true <- connected?(socket),
    #        {:ok, uuid} <- is_user_session?(session),
    #        :ok <- ensure_single_device(uuid),
    #        :ok <- Accounts.is_activated?(uuid),
    #        user_info <- Accounts.take(uuid, [:id, :username]) do
    #     Process.send_after(self(), :presence_info, 10_000)

    #     NyraWeb.Endpoint.subscribe("lobby")

    #     Presence.track(
    #       self(),
    #       "lobby",
    #       socket.id,
    #       %{
    #         current_user: uuid,
    #         online_at: :os.system_time(:seconds)
    #       }
    #     )

    #     send_update(Components.StatusBar,
    #       id: "status_bar",
    #       username: socket.assigns.username,
    #       user_id: socket.assigns.user_id,
    #       loading: socket.assigns.loading,
    #       online: socket.assigns.online_users_count
    #     )

    #     socket
    #     |> assign(socket,
    #       username: user_info.username,
    #       user_id: user_info.id,
    #       online_users_count: Presence.count_online(),
    #       loading: false
    #     )
    #   else
    #     false -> socket
    #     {:error, error} -> handle_error(socket, error)
    #   end
  end

  @doc "Handles error states by modifying the socket"
  def handle_error(socket, :no_token) do
    redirect(socket, to: app_path(socket, :index))
  end

  def handle_error(socket, :device_exists) do
    redirect(socket, to: app_path(socket, :index))
  end

  def handle_error(socket, :account_not_active) do
    redirect(socket, to: app_path(socket, :index))
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

  @impl true
  def handle_info(:presence_info, socket) do
    Process.send_after(self(), :presence_info, 10_000)
    {:noreply, assign(socket, online_users_count: Presence.count_online())}
  end

  @impl true
  def handle_info(:update, socket) do
    {:noreply, socket}
  end
end

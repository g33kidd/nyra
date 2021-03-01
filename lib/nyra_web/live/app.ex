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

  # ! NOTE do I need the loading state if not setting default state in @assign_defaults??
  @impl true
  def render(assigns) do
    ~L"""
    <%= if @loading do %>
      <%= live_component(@socket, Components.Loading, id: "loading") %>
    <% else %>
      <%= live_component(@socket, Components.StatusBar, [
        id: "status_bar",
        current_user: @current_user,
        loading: @loading,
        online: @online_users_count
      ]) %>

      <%= live_component(@socket, Components.ChatComposer, [
        id: "chat_composer",
        loading: @loading,
        current_user: @current_user,
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
          current_user: user,
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
  # def mount(%{}, _session, socket) do
  #   {:ok, assign(socket, @assign_defaults)}
  # end

  # This should be the first step in the "redirection".
  def mount(%{"token" => token}, _session, socket) do
    socket = assign(socket, @assign_defaults)

    socket =
      with {:ok, uuid} <- verify_token(socket, "user token", token),
           user <- Accounts.find(uuid) do
        IO.puts("here to redirect")
        socket
        # push_redirect(socket, to: app_path(socket, loading: false, current_user: user))
        # assign(socket, current_user: user, loading: false)
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
      |> IO.inspect()

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, @assign_defaults)

    socket =
      with true <- connected?(socket) do
        Process.send_after(self(), :presence_info, 500)
        Endpoint.subscribe("lobby")

        # OK WE CANT TRACK UNTIL WE GET THE UUID SO STOP TRYING
        # OK WE CANT TRACK UNTIL WE GET THE UUID SO STOP TRYING
        # OK WE CANT TRACK UNTIL WE GET THE UUID SO STOP TRYING
        # OK WE CANT TRACK UNTIL WE GET THE UUID SO STOP TRYING
        socket
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

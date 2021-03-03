defmodule NyraWeb.AppLive do
  use NyraWeb, :live_view

  alias Nyra.{LiveUpdates, Accounts, UserPool, Messaging}
  alias NyraWeb.{Components, Presence}
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
        content: @content
      ]) %>

      <%= live_component(@socket, Components.ChatComposer, [
        id: "composer",
        content: @content
      ]) %>
    </div>
    """
  end

  @impl true
  # TODO figure out how to tell if a socket has been Disconnected!
  # TODO remove the user from the UserPool when they're Disconnected
  # TODO fix Presence user count and implement separate Statistics module.
  def mount(_params, %{"token" => token}, socket) do
    # if is_nil(token), do: {:noreply, socket |> put_flash(:error, "Waiting on token..")}
    socket = assign(socket, @assign_defaults)

    with true <- connected?(socket),
         {:ok, uuid} <- verify_token(socket, "user token", token),
         :ok <- Accounts.is_activated?(uuid),
         user <- Accounts.take(uuid, [:id, :username]) do
      LiveUpdates.subscribe_live_view(self(), socket, uuid)
      Messaging.queue(self(), socket, uuid)

      new_assigns = [
        current_user: user,
        statistics: Presence.statistics("lobby"),
        online_users_count: Presence.count_online(),
        loading: false
      ]

      {:ok, assign(socket, new_assigns), temporary_assigns: new_assigns}
    else
      false ->
        {:ok, socket}

      {:error, :account_not_found} ->
        {:ok, assign(socket, error: "Account not found.")}

      {:error, error} ->
        IO.inspect("error")
        IO.inspect(error)
        {:ok, assign(socket, error: error), temporary_assigns: [error: error]}
    end
  end

  # # Nothing's in the session or params, so assume there is no user. Force to home page.
  # def mount(%{}, %{}, socket) do
  #   IO.inspect("hello")
  #   {:ok, redirect(socket, to: home_path(socket, :index))}
  # end

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
    Messaging.send(self(), content, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(message, socket) do
    IO.puts(message)
    {:noreply, socket}
  end
end

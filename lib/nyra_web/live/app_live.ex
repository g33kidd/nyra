defmodule NyraWeb.AppLive do
  use NyraWeb, :live_view

  alias Nyra.Accounts
  alias NyraWeb.{Router, Presence, Endpoint}
  alias Phoenix.Token

  # ! note or question for later...
  # this feels redundant? but I want the format a certain way for code readability so maybe not?
  def is_connected?(socket), do: if(connected?(socket), do: :ok, else: {:error, :not_connected})

  # This is a real user right?
  @doc """
  This is a real user right?
  Okay from my perspective, if a user has passed all checks before this during a request then...
  It's not right and someone is trying to do something? Maybe not necesssarily but there won't be a token.
  """
  def is_user_session?(%{"token" => token}) when is_binary(token) do
    Token.verify(Endpoint, "user token", token)
  end

  def is_user_session?(%{"token" => token}) when is_nil(token), do: {:error, :no_token}

  @doc """
  Makes sure someone isn't trying to use the same account multiple places for spamming or botting
  """
  @spec ensure_single_device(String.t()) :: :ok | {:error, :device_exists}
  def ensure_single_device(id) when is_binary(id) do
    presences = Presence.list_online()

    existing_device_count =
      Enum.map(presences, fn {_socket_id, presence} -> fetch_id(presence) end)
      |> Enum.count(fn user_id -> user_id == id end)

    if(existing_device_count > 0, do: {:error, :device_exists}, else: :ok)
  end

  @doc "Grabs the user id from the Presence meta map"
  def fetch_id(nil), do: nil
  def fetch_id(%{metas: [first | _]}), do: first.current_user

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
      with :ok <- is_connected?(socket),
           {:ok, user_id} <- is_user_session?(session),
           :ok <- ensure_single_device(user_id) do
        # Subscribe to the lobby and track this session in Presence
        Endpoint.subscribe("lobby")

        Presence.track(self(), "lobby", socket.id, %{
          current_user: user_id,
          online_at: :os.system_time(:seconds)
        })

        presence_count =
          Presence.list_online()
          |> Enum.count()

        user_info = Map.take(Accounts.get_user(user_id), [:username, :id])

        assigns = [
          current_user: user_info,
          online_users_count: presence_count,
          loading: false
        ]

        IO.inspect(assigns)

        assign(socket, assigns)
      else
        {:error, :no_token} -> redirect(socket, to: Router.Helpers.page_path(socket, :index))
        {:error, :device_exists} -> redirect(socket, to: Router.Helpers.page_path(socket, :index))
        {:error, :not_connected} -> redirect(socket, to: Router.Helpers.page_path(socket, :index))
        {:error, default_error} -> assign(socket, error: default_error)
      end

    {:ok, socket}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _payload}, socket) do
    presence_count =
      Presence.list_online()
      |> Enum.count()

    {:noreply, assign(socket, online_users_count: presence_count)}
  end
end

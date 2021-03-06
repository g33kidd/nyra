defmodule NyraWeb.Helpers do
  @moduledoc """
  Helpers that modify sessions and what not useful for controllers.

  # TODO do I need this?
  """

  import Phoenix.LiveView

  alias Phoenix.{LiveView, Token}
  alias NyraWeb.{Presence, Endpoint}

  @doc "Signs a token that can be a sent to a client for Plug.Conn"
  def sign_token(%Plug.Conn{} = _conn, salt, data) do
    Token.sign(Endpoint, salt, data)
  end

  def sign_token(%LiveView.Socket{} = _socket, salt, data) do
    Token.sign(Endpoint, salt, data)
  end

  @doc "Verifies a token for a Plug connection"
  def verify_token(%Plug.Conn{} = _conn, salt, token) do
    Token.verify(Endpoint, salt, token)
  end

  def verify_token(%LiveView.Socket{} = _socket, salt, token) do
    Token.verify(Endpoint, salt, token)
  end

  @doc """
  [is_user_session?] decides if the incoming request is from a client trying to authenticate with a token.
  This can be a fake token or a real token. Here we decide what it is.

  This is a real user right?
  Okay from my perspective, if a user has passed all checks before this during a request then...
  It's not right and someone is trying to do something? Maybe not necesssarily but there won't be a token.
  """
  def is_user_session?(%{"_csrf_token" => _csrf, "token" => token}) when is_binary(token) do
    Token.verify(Endpoint, "user token", token)
  end

  def is_user_session?(%{"_csrf_token" => _csrf, "token" => token}) when is_nil(token) do
    {:error, :no_token}
  end

  def is_user_session?(%{"_csrf_token" => _csrf}), do: {:error, :no_token}

  @doc """
  Makes sure someone isn't trying to use the same account multiple places for spamming or botting

  TODO make a post about how the Dialyzer caught not having a local return value.
  TODO it happened because our recursive function never matched for an empty List.

  Yeah this is pretty cool. This snippet removed will cause it to pickup:

      def ensure_single_device([], _id, acc), do: acc

  """
  @spec ensure_single_device(String.t()) :: :ok | {:error, :device_exists}
  def ensure_single_device(id) when is_binary(id) do
    NyraWeb.Presence.list_online()
    |> ensure_single_device(id)
    |> case do
      0 -> :ok
      _ -> {:error, :device_exists}
    end
  end

  def ensure_single_device(presences, id) do
    ensure_single_device(presences, id, 0)
  end

  def ensure_single_device([{_socket_id, presence} | t] = _presences, id, acc) do
    user_id = fetch_id(presence)
    acc = if user_id == id, do: acc + 1, else: acc
    ensure_single_device(t, id, acc)
  end

  def ensure_single_device(%{}, _id, acc), do: acc

  @doc "Grabs the user id from the Presence meta map"
  def fetch_id(nil), do: nil
  def fetch_id(%{metas: [first | _]}), do: first.current_user

  @doc """
  Signs a token for the current user in the socket.
  """
  def sign_token(socket, salt) do
    %{id: user_id} = socket.assigns.current_user
    Token.sign(Endpoint, salt, user_id)
  end

  @doc "Assigns a user to the UserPool"
  def pool(socket, uuid, params) do
    Nyra.UserPool.add(socket, uuid, params)
    socket
  end
end

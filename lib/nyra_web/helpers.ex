defmodule NyraWeb.Helpers do
  @moduledoc """
  Helpers that modify sessions and what not useful for controllers.
  """

  alias Phoenix.{LiveView, Token}
  alias NyraWeb.Endpoint

  @doc "Signs a token that can be a sent to a client for Plug.Conn"
  def sign_token(%Plug.Conn{} = _conn, salt, data) do
    Token.sign(Endpoint, salt, data)
  end

  def sign_token(%LiveView.Socket{} = _socket, salt, data) do
    Token.sign(Endpoint, salt, data)
  end

  @doc "Verifies a token for a Plug connection"
  def verify_token(%Plug.Conn{} = conn, salt, token) do
  end

  def verify_token(%LiveView.Socket{} = socket, salt, token) do
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
  """
  @spec ensure_single_device(String.t()) :: :ok | {:error, :device_exists}
  def ensure_single_device(id) when is_binary(id) do
    presences = NyraWeb.Presence.list_online()

    existing_device_count =
      Enum.map(presences, fn {_socket_id, presence} -> fetch_id(presence) end)
      |> Enum.count(fn user_id -> user_id == id end)

    if(existing_device_count > 0, do: {:error, :device_exists}, else: :ok)
  end

  @doc "Grabs the user id from the Presence meta map"
  def fetch_id(nil), do: nil
  def fetch_id(%{metas: [first | _]}), do: first.current_user

  @doc """
  Signs a token for the current user in the socket.

  ! TODO They should also be authorized..
  """
  def sign_token(socket, salt) do
    %{id: user_id} = socket.assigns.current_user
    Token.sign(Endpoint, salt, user_id)
  end
end

defmodule NyraWeb.LiveHelpers do
  @moduledoc """
  The purpose of this module is to help out when making requests with LiveView.

  We should have some authentication methods that set default assigns.

  Access to the session here so that would get rid of some code.
  """

  alias Phoenix.Token
  alias NyraWeb.Endpoint

  # import Phoenix.LiveView

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

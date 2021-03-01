defmodule NyraWeb.AuthController do
  use NyraWeb, :controller

  alias NyraWeb.Endpoint
  alias NyraWeb.Router, as: Routes
  alias Phoenix.Token

  import Routes.Helpers

  # Verifies a user by checking the given code with a code somewhere else.
  def verify(conn, %{"token" => nil}) do
    IO.inspect("empty")
    conn
  end

  def verify(conn, %{"token" => token}) do
    case Token.verify(Endpoint, "user token", token) do
      {:ok, user_id} ->
        conn
        |> put_session(
          :token,
          Token.sign(conn, "user token", user_id)
        )
        |> configure_session(renew: true)
        |> redirect(to: "/app")

      {:error, err} ->
        conn |> put_flash(:error, "Token isn't valid or expired. #{err}")
    end
  end

  # # Setup a session for authorization.
  # def create(conn, %{"token" => token} = _params) do
  #   case Token.verify(Endpoint, "user token", token) do
  #     {:ok, user_id} ->
  #       conn
  #       |> put_session(
  #         :token,
  #         Token.sign(conn, "user token", user_id)
  #       )
  #       |> configure_session(renew: true)
  #       |> redirect(to: "/app")

  #     {:error, err} ->
  #       conn |> put_flash(:error, "Token isn't valid or expired. #{err}")
  #   end
  # end

  # Destroys a session
  def destroy(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: home_path(conn, :index))
  end
end

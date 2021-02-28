defmodule NyraWeb.SessionController do
  # ! Marking for removal
  # ! Marking for removal
  # ! Marking for removal
  # ! Marking for removal
  # ! Marking for removal

  use NyraWeb, :controller

  alias NyraWeb.Endpoint
  alias NyraWeb.Router, as: Routes

  import Phoenix.Token, only: [verify: 3, sign: 3]

  def create(conn, %{"token" => token} = _params) do
    case Phoenix.Token.verify(Endpoint, "user token", token) do
      {:ok, user_id} ->
        conn
        |> put_session(
          :token,
          Phoenix.Token.sign(conn, "user token", user_id)
        )
        |> configure_session(renew: true)
        |> redirect(to: "/app")

      {:error, err} ->
        conn |> put_flash(:error, "Token isn't valid or expired. #{err}")
    end
  end

  def destroy(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: Routes.Helpers.page_path(conn, :index))
  end
end

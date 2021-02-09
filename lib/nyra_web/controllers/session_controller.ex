defmodule NyraWeb.SessionController do
  use NyraWeb, :controller

  alias NyraWeb.Router, as: Routes
  import Phoenix.LiveView.Controller, only: [live_render: 2]

  def create(conn, %{"token" => token} = _params) do
    case Phoenix.Token.verify(NyraWeb.Endpoint, "user token", token) do
      {:ok, user_id} ->
        conn
        |> put_session(
          :token,
          Phoenix.Token.sign(conn, "user token", user_id)
        )
        |> configure_session(renew: true)
        |> redirect(to: "/app")

      {:error, _err} ->
        conn |> put_flash(:error, "Token isn't valid.")
    end
  end

  def destroy(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: Routes.Helpers.page_path(conn, :index))
  end
end

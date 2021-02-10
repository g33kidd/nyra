defmodule NyraWeb.AppLive do
  use NyraWeb, :live_view

  alias NyraWeb.Router, as: Routes

  def mount(_params, session, socket) do
    assigns = [
      username: "123"
    ]

    socket =
      socket
      |> assign(assigns)

    if not is_nil(session["token"]) do
      {:ok, socket}
    else
      {:ok, redirect(socket, to: Routes.Helpers.page_path(socket, :index))}
    end
  end
end

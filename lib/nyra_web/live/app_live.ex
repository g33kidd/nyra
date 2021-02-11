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

    if is_nil(session["token"]) do
      {:ok, redirect(socket, to: Routes.Helpers.page_path(socket, :index))}
    else
      {:ok, socket}
    end
  end
end

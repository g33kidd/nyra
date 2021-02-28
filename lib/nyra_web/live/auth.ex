defmodule NyraWeb.Auth do
  use NyraWeb, :live_view

  import NyraWeb.Router.Helpers

  def render(assigns) do
    ~L"""
    <div phx-hook="AuthStore">
      Redirecting you to the application..
    </div>
    """
  end

  def mount(%{}, _session, socket) do
    {:noreply, redirect(socket, to: page_path(socket, :index))}
  end

  def mount(%{"token" => token}, _session, socket) do
  end
end

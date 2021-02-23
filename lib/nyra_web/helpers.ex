defmodule NyraWeb.Helpers do
  @moduledoc """
  Helpers that modify sessions and what not useful for controllers.
  """

  alias Phoenix.LiveView

  @doc "Signs a token that can be a sent to a client for Plug.Conn"
  def sign_token(%Plug.Conn{} = conn, salt, data) do
  end

  def sign_token(%LiveView.Socket{} = socket, salt, data) do
  end

  @doc "Verifies a token for a Plug connection"
  def verify_token(%Plug.Conn{} = conn, salt, token) do
  end

  def verify_token(%LiveView.Socket{} = socket, salt, token) do
  end
end

defmodule NyraWeb.Components.StatusBar do
  use Phoenix.LiveComponent

  def render(assigns) do
    IO.inspect(assigns)

    ~L"""
    <div>ID: <%= @user_id %></div>
    <div>Current User Count: <%= @username %></div>
    <div><%= @online %></div>
    """
  end
end

defmodule NyraWeb.Components.StatusBar do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div>ID: <%= @current_user.id %></div>
    <div>Current User Count: <%= @current_user.username %></div>
    <div><%= @online %></div>
    """
  end
end

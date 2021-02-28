defmodule NyraWeb.Components.StatusBar do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="statusbar">
      <div class="welcome">Hello, <%= @current_user.username %>!</div>
      <div class="online-count">Online Now <span><%= @online %></span></div>
    </div>
    """
  end
end

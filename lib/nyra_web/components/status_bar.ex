defmodule NyraWeb.Components.StatusBar do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="statusbar">
      <div class="welcome">Hello <strong><%= @current_user.username %></strong></div>
      <div class="user-count">
        <div class="header">Online Now</div>
        <div class="count">
          <span class="online"><%= @online %></span> / <span class="total">350</span>
        </div>
      </div>
    </div>
    """
  end
end

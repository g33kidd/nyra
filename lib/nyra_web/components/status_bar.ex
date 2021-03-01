defmodule NyraWeb.Components.StatusBar do
  use Phoenix.LiveComponent

  # TODO maybe use Preload method for loading a user?
  # def preload(assigns) do
  #   IO.inspect(assigns)
  # end

  def render(assigns) do
    ~L"""
    <div class="statusbar">
    <%= if is_nil(@current_user) do %>
    No user.
    <% else %>
    <div class="welcome">Hello <strong><%= @current_user.username %></strong></div>
    <div class="logo sm">Nyra</div>

      <div class="user-count">
        <div class="header">Online Now</div>
          <div class="count">
          <span class="online"><%= @online %></span> / <span class="total">350</span>
        </div>
      </div>
    <% end %>
    </div>
    """
  end
end

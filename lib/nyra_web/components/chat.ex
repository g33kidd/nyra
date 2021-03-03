defmodule NyraWeb.Components.Chat do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="chat">
      <%= for message <- @messages do %>
        <%= live_component @socket, Components.ChatMessage, id: message.id, message: message %>
      <% end %>
    </div>
    """
  end
end

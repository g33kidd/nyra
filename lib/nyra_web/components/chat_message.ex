defmodule NyraWeb.Components.ChatMessage do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="message user">
      <div class="author"><%= @message.author %></div>
      <div class="content"><%= @message.content %></div>
    </div>
    """
  end
end

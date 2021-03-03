defmodule NyraWeb.Components.ChatMessage do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="message user">
      <div class="author">self</div>
      <div class="content">
        Hello! Bored and just ate some amazing Pizza! How's your day?
      </div>
    </div>
    """
  end
end

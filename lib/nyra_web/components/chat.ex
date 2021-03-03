defmodule NyraWeb.Components.Chat do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="chat">

      <div class="message server">
        <div class="content">
          You've been matched with another user! Say something to get the conversation started. Harassment will not be tolerated.
        </div>
        <div class="notice important">
        </div>
      </div>

      <div class="message user">
        <div class="author">self</div>
        <div class="content">
          Hello! Bored and just ate some amazing Pizza! How's your day?
        </div>
      </div>

      <div class="message user">
        <div class="author">Username</div>
        <div class="content">
          What was on the Pizza?
        </div>
      </div>

      <div class="message server disconnect">
        <div class="content">
          <span>User has disconnected.</span> Attempting to reconnect or move on...
        </div>
        <div class="notice important">
        </div>
      </div>
    </div>
    """
  end
end

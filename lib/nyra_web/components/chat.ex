defmodule NyraWeb.Components.Chat do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="chat">

      <div class="message server">
        <div class="author">NyraBot</div>
        <div class="content">
          You've been matched with another user! Say something to get the conversation started. Harassment will not be tolerated.
        </div>
        <div class="notice important">
        </div>
      </div>

      <div class="message user">
        <div class="author">me</div>
        <div class="content">
          Hello! Bored and just ate some amazing Pizza! How's your day?
        </div>
      </div>

      <div class="message user">
        <div class="author">PatientCherry</div>
        <div class="content">
          What was on the Pizza?
        </div>
      </div>

      <div class="message user">
        <div class="author">me</div>
        <div class="content">
        ... Shrimp! It was so interesting, if you get the chance you should try it! It has some weird flavors but delicious!
        </div>
      </div>

      <div class="message user">
        <div class="author">PatientCherry</div>
        <div class="content">
          That doesn't sound really great to me 🤮
        </div>
      </div>

      <div class="message user">
        <div class="author">me</div>
        <div class="content">
        It's okay, shrimp is weird.
        </div>
      </div>

      <div class="message server disconnect">
        <div class="author">NyraBot</div>
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

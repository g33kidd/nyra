defmodule NyraWeb.AboutLive do
  use NyraWeb, :live_view

  def render(assigns) do
    ~L"""
    <div class="about">
      <div class="header">
        <div class="logo">Nyra</div>
      </div>
      <div class="content"></div>

      <div class="faq">
        <div class="title">Frequently Asked Questions</div>

        <ul>
          <li>My account is gone, where did it go? User accounts are deleted automatically after 3 days of inactivity. This keeps the system anonymous and affordable.</li>
          <li>Username changed, what gives? Usernames are constantly changing to protect you. We only use usernames to display in Chat rooms, so none of your data is compromised :)</li>
          <li>What can't I talk to anybody? You're probably banned, git rekt.</li>
        </ul>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

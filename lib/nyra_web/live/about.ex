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
        <div class=""></div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

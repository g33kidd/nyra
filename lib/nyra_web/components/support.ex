defmodule NyraWeb.Components.SupportLinks do
  use NyraWeb, :live_component

  import NyraWeb.Router.Helpers, only: [home_path: 2]

  def render(assigns) do
    ~L"""
    <div class="support">
      <div class="content">SUPPORT</div>
      <%= live_patch "$2", to: home_path(@socket, :index), amount: 2 %>
      <%= live_patch "$4", to: home_path(@socket, :index), amount: 4 %>
      <%= live_patch "$8", to: home_path(@socket, :index), amount: 8 %>
    </div>
    """
  end
end

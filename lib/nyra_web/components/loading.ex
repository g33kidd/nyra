defmodule NyraWeb.Components.Loading do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="loading">
    Loading...
    </div>
    """
  end
end

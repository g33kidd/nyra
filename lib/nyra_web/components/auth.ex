defmodule NyraWeb.Components.Auth do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <form phx-submit="authenticate" >
      <input
        type="email"
        name="email"
        value="<%= @email_input %>"
        placeholder="Email Address"
        autocomplete="off" />
      <button
        type="submit"
        phx-disable-with="Working...">LOGIN</button>
    </form>
    """
  end
end

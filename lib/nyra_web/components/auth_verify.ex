defmodule NyraWeb.Components.AuthVerify do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <form phx-submit="verify">
    <input
      type="text"
      name="code"
      value="<%= @code_input %>"
      placeholder="Enter code here.."
      autocomplete="off" />
    <button
      type="submit"
      phx-disable-with="Verifying code...">VERIFY</button>
    </form>
    """
  end
end

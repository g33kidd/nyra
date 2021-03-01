defmodule NyraWeb.Components.ChatComposer do
  use Phoenix.LiveView

  # TODO add phx-disabled-with when there's a variable to bind it to.
  @impl true
  def render(assigns) do
    ~L"""
    <div class="composer">
      <form phx-submit="composeMessage" phx-target="<%= @myself %>">
        <input type="text" placeholder="Message" value="<%= @email_input %>" />
        <button type="submit" text="Submit" />
      </form>
    </div>
    """
  end

  @impl true
  def handle_event(event, _, socket) do
    IO.inspect(event)
    {:noreply, socket}
  end
end

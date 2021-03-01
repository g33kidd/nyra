defmodule NyraWeb.Components.ChatComposer do
  use Phoenix.LiveComponent

  # TODO add phx live hook to reset input value and keep focus..
  # TODO add contenteditable div instead of a text input, for rich text support?
  @impl true
  def render(assigns) do
    ~L"""
    <form phx-submit="send" phx-target="<%= @myself %>" class="composer">
      <input type="text" name="content" placeholder="Message" autocomplete="off" value="<%= @content %>" />
      <button type="submit" phx-disable-with="Sending...">
        Send
      </button>
    </form>
    """
  end

  @impl true
  # TODO should handle some content parsing/formatting for emotes/embeds or whatever..
  def handle_event("send", %{"content" => content}, socket) do
    send(self(), {:compose_message, content})
    {:noreply, socket}
  end
end

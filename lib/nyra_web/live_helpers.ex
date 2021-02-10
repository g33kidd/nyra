defmodule NyraWeb.LiveHelpers do
  import Phoenix.LiveView

  # ! not really sure we need this method here...
  def assign_defaults(session, socket) do
    # socket = assign(socket, current_user: %{username: session.assigns.current_user})

    if socket.assigns.current_user do
      socket
    else
      redirect(socket, to: "/login")
    end
  end

  # defp find_current_user(session) do
  #   with user_token when not is_nil(user_token) <- session["user_token"] do
  #   end
  # end

  # TODO helpers for changes in authenticaiton and what not.
end

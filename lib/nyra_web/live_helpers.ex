defmodule NyraWeb.LiveHelpers do
  import Phoenix.LiveView

  # ! not really sure we need this method here...
  # def assign_defaults(%{"user_id" => id}, socket) do
  #   socket = assign(socket, current_user: %{username: id})

  #   if socket.assigns.current_user do
  #     socket
  #   else
  #     redirect(socket, to: "/login")
  #   end
  # end

  # TODO helpers for changes in authenticaiton and what not.
end

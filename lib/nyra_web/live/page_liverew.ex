defmodule NyraWeb.PageLiveRew do
  # !NOTE keep in mind separation of concerns.
  # ! mount is okay...

  @impl true
  @doc "Handles the authentication form submit method."
  def handle_event("authenticate", data, socket) do
    # with {:ok, code} <- Bouncer.generate_code(socket.id),
    #      {:ok, user, user_type} <- Accounts.find_or_create_user() do
    # else
    #   {:error, error_changeset} -> assign(socket, errors: changeset.errors)
    # end
  end

  @impl true
  @doc "Handles the verify form submit method."
  def handle_event("verify", data, socket) do
  end
end

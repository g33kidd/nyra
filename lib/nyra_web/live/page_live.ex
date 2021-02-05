defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  alias Nyra.Bouncer
  alias Nyra.Accounts
  alias Nyra.Accounts.User

  @welcome_msg "Thanks for joining Nyra! We're currently in Beta, so please let us know what you think ^_^"
  @welcome_back "Welcome back!"

  @impl true
  def mount(_params, _session, socket) do
    user_changeset = Accounts.create_user_changeset()

    assigns = [
      email: "",
      code: "",
      changeset: user_changeset,
      error_message: "",
      awaiting_code: nil,
      current_user: nil,
      new_user: nil,
      success: false
    ]

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("authenticate", %{"email" => email}, socket) do
    {:noreply, authenticate(socket, email)}
  end

  @impl true
  def handle_event("verify", %{"code" => code}, socket) do
    case Bouncer.is_cool?(code) do
      :ok -> {:noreply, socket |> assign(success: true)}
      {:error, msg} -> {:noreply, socket |> assign(error_message: msg)}
      nil -> {:noreply, socket |> assign(error_message: "idk")}
    end
  end

  defp authenticate(socket, email) do
    case Accounts.find_or_create_user(%{"email" => email}) do
      {:created, user} -> handle_no_user(socket, user)
      {:ok, user} -> handle_with_user(socket, user)
      {:error, changeset} -> {:error, changeset}
    end
  end

  # Modifies and returns a new socket with information regarding an existing user.
  defp handle_with_user(socket, user) do
    with {:ok, code} <- Bouncer.guestlist(socket.id) do
      Nyra.Emails.login_link(code, user)
      |> Nyra.Mailer.deliver_later()

      socket
      |> put_flash(:welcome_back, @welcome_back)
      |> assign(new_user: false)
      |> assign(current_user: user)
      |> assign(awaiting_code: true)
    end
  end

  defp handle_no_user(socket, user) do
    socket
    |> put_flash(:welcome, @welcome_msg)
    |> assign(new_user: true)
    |> assign(awaiting_code: true)
    |> assign(current_user: user)
  end
end

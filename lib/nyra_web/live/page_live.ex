defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  alias Nyra.Bouncer
  alias Nyra.Accounts

  @welcome_msg "Thanks for joining Nyra! We're currently in Beta, so please let us know what you think ^_^"
  @welcome_back "Welcome back!"

  @impl true
  def mount(_params, _session, socket) do
    user_changeset = Accounts.create_user_changeset()

    assigns = [
      email: "",
      generated_code: nil,
      code: nil,
      code_input: "",
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
    socket =
      case verify_code(code, socket.assigns.generated_code) do
        :ok ->
          socket
          |> assign(success: true)

        :invalid ->
          socket
          |> assign(error_message: "Invalid code.")
      end

    {:noreply, socket}
  end

  def verify_code(input, real), do: if(input == real, do: :ok, else: :invalid)

  defp authenticate(socket, email) do
    code = Bouncer.generate_code(email)
    socket = assign(socket, generated_code: code)

    case Accounts.find_or_create_user(%{"email" => email}) do
      {:created, user} -> handle_no_user(socket, {code, user})
      {:ok, user} -> handle_with_user(socket, {code, user})
      {:error, changeset} -> {:error, changeset}
    end
  end

  # Modifies and returns a new socket with information regarding an existing user.
  defp handle_with_user(socket, {code, user}) do
    Nyra.Emails.login_link(code, user)
    |> Nyra.Mailer.deliver_later()

    socket
    |> put_flash(:welcome_back, @welcome_back)
    |> assign(new_user: false)
    |> assign(current_user: user)
    |> assign(awaiting_code: true)
  end

  defp handle_no_user(socket, user) do
    socket
    |> put_flash(:welcome, @welcome_msg)
    |> assign(new_user: true)
    |> assign(awaiting_code: true)
    |> assign(current_user: user)
  end
end

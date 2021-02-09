defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  alias NyraWeb.Router, as: Routes
  alias Nyra.{Bouncer, Accounts}

  @impl true
  def mount(_params, session, socket) do
    assigns = [
      # Private stuff
      generated_username: Accounts.generate_username(),
      generated_code: nil,

      # Text Input Fields
      email_input: "yo@gmail.com",
      code_input: "",

      # Welcome Message when authentication finishes.
      welcome_message: "",
      welcome_type: :new_user,

      # Error state
      error: nil,

      # current_state | :init, :awaiting_code, :authenticated, :error, :timeout, :account_created
      # user_type | :new, :existing
      current_state: :init,
      user_type: :new
    ]

    # Redirects user to the app if they're already authenticated.
    if session["token"] do
      {:ok, redirect(socket, to: Routes.Helpers.app_path(socket, :index))}
    else
      {:ok, assign(socket, assigns)}
    end
  end

  @impl true
  def handle_event("authenticate", %{"email" => email}, socket) do
    code = Bouncer.generate_code(socket.id)

    socket =
      case Accounts.find_or_create_user(%{"email" => email}, socket.assigns.generated_username) do
        {:created, user} ->
          socket
          |> assign(current_state: :awaiting_code)
          |> assign(current_user: user)
          |> assign(user_type: :new)

        {:ok, user} ->
          socket
          |> assign(current_state: :awaiting_code)
          |> assign(current_user: user)
          |> assign(user_type: :existing)

        {:error, changeset} ->
          socket
          |> assign(error: changeset.errors)
      end
      |> assign(generated_code: code)

    if socket.assigns.current_state == :awaiting_code and socket.assigns.current_user != nil do
      Nyra.Emails.login_link(code, socket.assigns.current_user)
      |> Nyra.Mailer.deliver_later()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("verify", %{"code" => code}, socket) do
    case if(code == socket.assigns.generated_code, do: :ok, else: :invalid) do
      :ok ->
        token = Phoenix.Token.sign(NyraWeb.Endpoint, "user token", socket.assigns.current_user.id)

        {:noreply, redirect(socket, to: Routes.Helpers.session_path(socket, :create, token))}

      :invalid ->
        {:noreply,
         socket
         |> assign(current_state: :awaiting_code)
         |> assign(error: "Invalid code.")}
    end
  end
end

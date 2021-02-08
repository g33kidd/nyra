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
      # Private stuff
      generated_code: nil,
      user_changeset: user_changeset,

      # Text Input Fields
      email: "",
      code_input: "",

      # Welcome Message when authentication finishes.
      welcome_message: "",
      welcome_type: :new_user,

      # Error state
      error: nil,

      # States
      # Possible values | :init, :awaiting_code, :authenticated, :error, :timeout, :account_created
      current_state: :init,
      # :new, :existing
      user_type: :new
    ]

    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event("authenticate", %{"email" => email}, socket) do
    code = Bouncer.generate_code(email)

    socket =
      case Accounts.find_or_create_user(%{"email" => email}) do
        {:created, user} ->
          socket
          |> assign(current_state: :awaiting_code)
          |> assign(current_user: user)
          |> assign(user_type: :new)

        {:ok, user} ->
          socket
          |> assign(current_state: :awaiting_code)
          |> assign(current_user: user)
          |> assign(uesr_type: :existing)

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
    socket =
      case if(code == socket.assigns.generated_code, do: :ok, else: :invalid) do
        :ok ->
          socket
          |> assign(current_state: :authenticated)

        :invalid ->
          socket
          |> assign(error: "Invalid code.")
      end

    {:noreply, socket}
  end
end

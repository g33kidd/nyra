defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  alias NyraWeb.Router, as: Routes
  alias Nyra.{Bouncer, Accounts, Mailer, Emails}

  @impl true
  def mount(_params, session, socket) do
    assigns = [
      # Private stuff
      generated_username: nil,
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

  @doc """
  Handles the "authenticate" event from the LiveView form.
  """
  @impl true
  def handle_event("authenticate", %{"email" => email}, socket) do
    socket =
      with {:ok, code} <- Bouncer.generate_code(socket.id),
           {:ok, user, user_type} <- Accounts.find_or_create_user(email) do
        assign(socket,
          current_state: :awaiting_code,
          current_user: user,
          user_type: user_type,
          generated_code: code
        )

        Emails.login_link(code, user) |> Mailer.deliver_later()
      else
        {:error, changeset} -> assign(socket, error: changeset.errors)
      end

    {:noreply, socket}
  end

  @impl true
  @doc "Handles the verify form submission"
  def handle_event("verify", %{"code" => code}, socket) do
    socket =
      with true <- String.match?(code, socket.assigns.generated_code),
           token <- sign_token(socket, "user token") do
        redirect(socket, to: Routes.Helpers.session_path(socket, :create, token))
      else
        false -> assign(socket, error: "Invalid code.")
        _default -> assign(socket, error: "Invalid code.")
      end

    {:noreply, socket}
  end
end

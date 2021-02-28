defmodule NyraWeb.AuthLive do
  # ! Marking this for removal
  # ! Marking this for removal
  # ! Marking this for removal
  # ! Marking this for removal
  # ! Marking this for removal

  use NyraWeb, :live_view

  alias Nyra.{Bouncer, Accounts, Mailer, Emails}

  import NyraWeb.Router.Helpers, only: [session_path: 3, app_path: 2]

  # TODO how can I separate the concerns of page_live.html
  @impl true
  def render(assigns) do
    ~L"""
    <div class="centered">
    <article class="box auth">

    <div class="content pad">
    <h1>Authentication</h1>
    <p class="text">
      Complete the steps below to get access to Nyra. We've made this process simple: just enter your email address and enter the code sent to your inbox.
    </p>
    <p class="text sub highlight">
      Note: Your email address is not shared with anybody.
    </p>
    </div>

    <%= case @current_state do %>

    <%# Init State %>
    <%= :init -> %>
    <form phx-submit="authenticate">
      <input
        type="email"
        name="email"
        value="<%= @email_input %>"
        placeholder="Email Address"
        autocomplete="off" />
      <button
        type="submit"
        phx-disable-with="Working...">LOGIN</button>
    </form>

    <%# User is waiting for a code. %>
    <% :awaiting_code -> %>
    <%= if @user_type == :existing do %>
      <p class="center pad">🚀 Welcome back! Just check your email for the code..</p>
    <% end %>

    <form phx-submit="verify">
      <input
        type="text"
        name="code"
        value="<%= @code_input %>"
        placeholder="Enter code here.."
        autocomplete="off" />
      <button
        type="submit"
        phx-disable-with="Verifying code...">VERIFY</button>
    </form>

    <%= if !is_nil(@error) do %>
      <p class="error">The code might be expired or invalid.</p>
    <% end %>

    <% :authenticated -> %>
    <p>Good job you are in!</p>
    <p>Setting up...</p>

    <%# This is really only the case when the toke expires... %>
    <% :timeout -> %>

    <%# Most likely if an email has already been used. %>
    <% :error -> %>


    <% end %>

    </article>
    </div>

    """
  end

  @impl true
  def mount(_params, session, socket) do
    if session["token"],
      do: {:ok, redirect(socket, to: app_path(socket, :index))}

    assigns = [
      # Private stuff
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

    {:ok, assign(socket, assigns)}
  end

  @doc """
  Handles the "authenticate" event from the LiveView form.
  """
  @impl true
  def handle_event("authenticate", %{"email" => email}, socket) do
    {:ok, code} = Bouncer.generate_code(socket.id)

    socket =
      with {:ok, user, user_type} <-
             Accounts.find_or_create_user(email) do
        # TODO move this somewhere else?
        Emails.login_link(email, code: code)
        |> Mailer.deliver_later()

        assign(socket,
          current_state: :awaiting_code,
          current_user: user,
          user_type: user_type,
          generated_code: code
        )
      else
        {:error, changeset} -> assign(socket, error: changeset.errors)
      end

    {:noreply, socket}
  end

  @impl true
  @doc "Handles the verify form submission"
  def handle_event("verify", %{"code" => code}, socket) do
    socket =
      with true <-
             String.equivalent?(code, socket.assigns.generated_code) do
        token =
          sign_token(
            socket,
            "user token",
            socket.assigns.current_user.id
          )

        redirect(socket, to: session_path(socket, :create, token))
      else
        false -> assign(socket, error: "Invalid code.")
        _default -> assign(socket, error: "Invalid code.")
      end

    {:noreply, socket}
  end
end

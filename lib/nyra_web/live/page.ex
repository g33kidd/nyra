defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  alias NyraWeb.Components
  alias Nyra.{Emails, Mailer, Accounts, Bouncer}

  import NyraWeb.Router.Helpers, only: [session_path: 3, app_path: 2]

  @default_assigns [
    current_state: "init",
    email_input: "yo@gmail.com",
    code_input: nil,
    error: nil
  ]

  @impl true
  def render(assigns) do
    ~L"""
    <div class="hero">

      <div class="title logo">Nyra</div>
      <div class="subtitle">Blah blah blah blah.</div>
      <div class="content">
      I'm baby roof party literally lumbersexual crucifix four dollar toast. Kitsch PBR&B truffaut, +1 gluten-free tattooed leggings freegan jianbing tumeric chia pour-over helvetica.
      </div>

      <%= case @current_state do %>
        <%= "init" -> %>
        <%= live_component(@socket, Components.Auth, id: "authentication", email_input: @email_input) %>

        <% "code" -> %>
        <%= live_component(@socket, Components.AuthVerify, id: "auth_verify", code_input: @code_input) %>

        <% "authenticated" -> %>
        <%= live_component(@socket, Components.AuthWelcome, id: "auth_welcome") %>

        <% "timeout" -> %>
        <%= live_component(@socket, Components.AuthTimeout, id: "auth_timeout") %>

        <% "error" -> %>
          <h1>There has been an "Error" <%= @error %></h1>
    <% end %>

    </div>
    """
  end

  @impl true
  @doc "Handles authentication form from [Components.Auth]"
  def handle_event("authenticate", %{"email" => email}, socket) do
    {:ok, code} = Bouncer.generate_code(socket.id)

    socket =
      with {:ok, user, user_type} <- Accounts.find_or_create_user(email) do
        # TODO move this somewhere else?
        Emails.login_link(email, code: code)
        |> Mailer.deliver_later()

        assign(socket,
          current_state: "code",
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
      with true <- String.equivalent?(code, socket.assigns.generated_code) do
        token = sign_token(socket, "user token", socket.assigns.current_user.id)
        redirect(socket, to: session_path(socket, :create, token))
      else
        false -> assign(socket, error: "Invalid code.")
        _default -> assign(socket, error: "Invalid code.")
      end

    {:noreply, socket}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, loading: false)}
  end
end

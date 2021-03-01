defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  alias NyraWeb.Components
  alias Nyra.{Accounts, Bouncer}

  import NyraWeb.Router.Helpers

  def mount(_params, session, socket) do
    if is_nil(session["token"]) do
      {:ok,
       assign(socket,
         current_state: "init",
         email_input: "yo@gmail.com",
         code_input: nil,
         error: nil
       )}
    else
      {:ok, redirect(socket, to: app_path(socket, :index))}
    end
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="hero" id="hero">

      <div class="title logo">Nyra</div>
      <div class="subtitle">Blah blah blah blah.</div>
      <div class="content">
      I'm baby roof party literally lumbersexual crucifix four dollar toast. Kitsch PBR&B truffaut, +1 gluten-free tattooed leggings freegan jianbing tumeric chia pour-over helvetica.
      </div>

      <%= case @current_state do %>
        <%= "init" -> %>
        <%= live_component(@socket, Components.Auth, id: "authenticate", email_input: @email_input) %>

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
  def handle_event("authenticate", %{"email" => email}, socket) do
    socket =
      with {:ok, code} <- Bouncer.generate_code(socket.id),
           {:ok, user, user_type} <- Accounts.find_or_create_user(email) do
        Accounts.deliver_code(email, code)

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
  def handle_event("verify", %{"code" => code}, socket) do
    id = socket.assigns.current_user.id

    socket =
      with true <- String.equivalent?(code, socket.assigns.generated_code),
           token <- sign_token(socket, "user token", id) do
        Accounts.find(id) |> Accounts.activate()
        redirect(socket, to: auth_path(socket, :verify, token, %{token: token}))
      else
        false -> assign(socket, error: "Invalid code.")
        _default -> assign(socket, error: "Invalid code.")
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("token_restore", %{"token" => nil}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("token_restore", %{"token" => _token}, socket) do
    {:noreply, socket}
  end
end

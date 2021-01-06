defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  alias Nyra.Accounts
  alias Nyra.Accounts.User

  @welcome_msg "Thanks for joining Nyra! We're currently in Beta, so please let us know what you think ^_^"

  @impl true
  def mount(_params, _session, socket) do
    user_changeset = Accounts.create_user_changeset()

    assigns = [
      email: "",
      code: "",
      real_code: "",
      changeset: user_changeset,
      error_message: "",
      awaiting_code: nil,
      current_user: nil,
      new_user: nil
    ]

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("authenticate", %{"email" => email}, socket) do
    {:noreply, authenticate(socket, email)}
  end

  @impl true
  def handle_event("verify", %{"code" => code}, socket) do
    with :ok <- Nyra.Bouncer.check(socket.id, code) do
      socket =
        socket
        |> put_flash(:info, "You're in! Congrats..")

      {:noreply, socket}
    else
      nil -> {:noreply, assign(socket, :error_message, "Invalid code.")}
      {:error, ugh} -> {:noreply, assign(socket, :error_message, ugh)}
      :else -> {:noreply, assign(socket, :error_message, "Not sure this time..")}
    end
  end

  defp authenticate(socket, email) do
    # Find or create user based on the Email Address.
    # Create the user.
    # Assign the Bouncer code to the socket.

    case Accounts.find_or_create_user(%{"email" => email}) do
      {:created, user} -> handle_no_user(socket, user)
      {:ok, user} -> handle_with_user(socket, user)
      {:error, changeset} -> {:error, changeset}
    end

    # case Accounts.get_user_by(email: email) do
    #   {:ok, nil} ->
    #     handle_no_user(assign(socket, :changeset, changeset))

    #   {:ok, user} ->
    #     handle_with_user(assign(socket, :changeset, changeset), user)
    # end
  end

  # Modifies and returns a new socket with information regarding an existing user.
  defp handle_with_user(socket, user) do
    Nyra.Bouncer.assign_code(socket.id)
    |> IO.inspect()

    socket
    |> assign(new_user: false)
    |> assign(current_user: user)
    |> assign(awaiting_code: true)
  end

  defp handle_no_user(socket, user) do
    Nyra.Bouncer.assign_code(socket.id)

    socket
    |> assign(new_user: true)
    |> assign(awaiting_code: true)
    |> assign(current_user: user)
    |> put_flash(:welcome, @welcome_msg)
  end

  # @impl true
  # def handle_info("verify_user:" <> user, socket) do
  #   Phoenix.PubSub.broadcast(Nyra.PubSub, "verify_user:" <> user, {})

  #   {:noreply, socket}
  # end

  # @impl true
  # def handle_event("authenticate", %{"email" => _email}, socket) do
  #   socket = socket |> assign(waiting_verification: true)
  #   {:noreply, socket}
  # end

  # @impl true
  # def handle_event("search", %{"q" => query}, socket) do
  #   case search(query) do
  #     %{^query => vsn} ->
  #       {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

  #     _ ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:error, "No dependencies found matching \"#{query}\"")
  #        |> assign(results: %{}, query: query)}
  #   end
  # end

  # defp search(query) do
  #   if not NyraWeb.Endpoint.config(:code_reloader) do
  #     raise "action disabled when not in development"
  #   end

  #   for {app, desc, vsn} <- Application.started_applications(),
  #       app = to_string(app),
  #       String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
  #       into: %{},
  #       do: {app, vsn}
  # end
end

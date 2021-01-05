defmodule NyraWeb.PageLive do
  use NyraWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # ! not really sure we need this since not passing messages...
    # if connected?(socket) do
    #   Phoenix.PubSub.subscribe(Nyra.PubSub, "verify_user:123")
    # end

    socket =
      socket
      |> assign(email: "")
      |> assign(awaiting_code: false)
      |> assign(current_user: nil)

    {:ok, socket}
  end

  def handle_event("authenticate", %{"email" => email}, socket) do
    socket =
      socket
      |> assign(awaiting_code: true)
      |> put_flash(:info, "Waiting for verification code...")

    {:noreply, socket}
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

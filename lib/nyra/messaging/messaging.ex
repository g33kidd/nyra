defmodule Nyra.Messaging do
  @moduledoc """
  The [Messaging] server is responsible for keeping track of connected chats.
  Since we're keeping track of users states in the [UserPool] we keep track of connected users here.
  """
  use Nyra, :gen_server

  @impl true
  def init(state \\ %{}) do
    {:ok, state}
  end

  # GenServer API and data format
  def start_link(_), do: GenServer.start_link(@name, %{}, name: @name)
  def cast(event, payload), do: GenServer.cast(@name, {event, payload})
  def call(event, payload), do: GenServer.call(@name, {event, payload})

  @doc "Queue a user into the Messaging system and match them."
  def queue(pid, socket, uuid), do: call(:queue, pid: pid, socket: socket, uuid: uuid)

  # Handles matching a user with another user based on search params, then notify.
  @impl true
  def handle_call({:queue, [pid: pid, socket: socket, uuid: uuid]}, _from, state) do
    {:reply, :ok, state}
  end
end

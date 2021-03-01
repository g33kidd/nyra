defmodule Nyra.Messaging do
  @moduledoc """
  The [Messaging] server is responsible for keeping track of connected chats.
  Since we're keeping track of users states in the [UserPool] we keep track of connected users here.
  """

  @name __MODULE__

  @max_users 4
  @min_users 2

  @impl true
  def init(state \\ %{}) do
    # :timer.send_interval(50_000, @name, :cleanup)
    {:ok, state}
  end

  def start_link(_), do: GenServer.start_link(@name, %{}, name: @name)
  def cast(event, payload), do: GenServer.cast(@name, {event, payload})
  def call(event, payload), do: GenServer.call(@name, {event, payload})
end

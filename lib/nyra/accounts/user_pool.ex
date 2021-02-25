defmodule Nyra.UserPool do
  @moduledoc """

  UserPool is a collection of user ids that are currently tracked in presence.
  There is some additional information that is stored in the state here
    {waiting?, filters[], extra%{}}


  %{
    "xxx-xxx-xxx" => {0,}
  }



  """

  use GenServer

  @name __MODULE__

  @doc false
  def start_link(_) do
    GenServer.start_link(@name, %{}, name: @name)
  end

  @doc "Adds a user to the UserPool with default settings using the UUID."
  def add_user(id, defaults \\ {0, [], 0}) do
    GenServer.call(@name, {:add_user, id, defaults})
  end

  @doc "Removes a user from the UserPool using the UUID."
  def remove_user(id) do
    GenServer.cast(@name, {:remove_user, id})
  end

  def read_state, do: GenServer.call(@name, :read_state)

  @impl true
  def init(state \\ %{}) do
    :timer.send_interval(30_000, @name, :cleanup)
    {:ok, state}
  end

  # Callbacks

  @impl true
  def handle_call({:add_user, id, defaults}, _from, state) do
    state = Map.put(state, id, defaults)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:read_state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_cast({:remove_user, _id}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    # IO.puts("Cleaned below:")

    # state
    # |> cleanup()
    # |> IO.inspect()

    {:noreply, state}
  end

  # Private

  defp cleanup(state), do: cleanup(state, %{})

  defp cleanup([{_uuid, data} | t], new_state) do
    {_waiting, _filters, _} = data
    cleanup(t, new_state)
  end

  defp cleanup(%{}, new_state), do: new_state
end

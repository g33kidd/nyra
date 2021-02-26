defmodule Nyra.UserPool do
  @moduledoc """

  UserPool is a collection of user ids that are currently tracked in presence.
  There is some additional information that is stored in the state here

    {
      waiting?
      socket_id,
      params
    }

    - socket_id holds the users socket id so we can disconnected them if needed.
    - waiting tells whether or not this user is waiting to be connected with another.
    - params holds some useful information when matching other users.

    TODO make a note for storing filter information in the params.


  """

  use GenServer

  @name __MODULE__

  @doc false
  def start_link(_) do
    GenServer.start_link(@name, %{}, name: @name)
  end

  @doc "Adds a user to the UserPool with default settings using the UUID."
  def add(socket, uuid, params) do
    GenServer.call(
      @name,
      {:add_user, uuid, socket, params}
    )
  end

  @doc "Removes a user from the UserPool using the UUID."
  def remove(uuid) do
    GenServer.cast(
      @name,
      {:remove_user, uuid}
    )
  end

  @doc "Update param information for a certain UUID"
  def update(uuid, params) do
    GenServer.call(
      @name,
      {:update, uuid, params}
    )
  end

  @doc "Reads the state, for development only really"
  def read_state, do: GenServer.call(@name, :read_state)

  @impl true
  def init(state \\ %{}) do
    :timer.send_interval(30_000, @name, :cleanup)
    {:ok, state}
  end

  # Callbacks

  @impl true
  def handle_call({:add_user, uuid, socket, params}, _from, state) do
    # Params is basically settings that other users trying to matchup with should know about.
    # Such as age range, gender, etc..
    # NOTE: Refer to the @moduledoc for what params data carries
    data = {0, socket.id, params}
    state = Map.put(state, uuid, data)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:read_state, _from, state), do: {:reply, state, state}

  @impl true
  @doc "Pretty much handles cleaning up the UserPool when it gets busy."
  def handle_info(:cleanup, state) do
    state = cleanup(state)
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

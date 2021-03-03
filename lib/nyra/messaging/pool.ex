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

  use Nyra, :gen_server

  @session_length 300_000

  @impl true
  def init(state \\ %{}) do
    :timer.send_interval(30_000, @name, :cleanup)
    {:ok, state}
  end

  def start_link(_), do: GenServer.start_link(@name, %{}, name: @name)
  def cast(event, payload), do: GenServer.cast(@name, {event, payload})
  def call(event, payload), do: GenServer.call(@name, {event, payload})

  @doc "Adds a user to the UserPool with default settings using the UUID."
  def add(socket, uuid, params), do: call(:add_user, uuid: uuid, socket: socket, params: params)

  @doc "Removes a user from the UserPool using the UUID."
  def remove(uuid), do: cast(:remove_user, uuid: uuid)

  @doc "Update param information for a certain UUID"
  def update(uuid, params), do: call(:update, uuid: uuid, params: params)

  # Callbacks

  @impl true
  def handle_call({:add_user, [uuid: uuid, socket: socket, params: opts]}, _from, state) do
    params =
      opts ++
        [
          exp: :os.system_time(:seconds) + @session_length
        ]

    data = {0, socket.id, params}
    state = Map.put(state, uuid, data)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:read_state, _from, state), do: {:reply, state, state}

  @impl true
  @doc "Pretty much handles cleaning up the UserPool when it gets busy."
  # TODO fix the cleanup method because it just removes everything at this point, it's useless.
  def handle_info(:cleanup, state) do
    {:noreply, state}
  end
end

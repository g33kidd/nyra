defmodule Nyra.Bouncer do
  @moduledoc """
  [Bouncer] was created to authenticate a user on Nyra without a password.

  The state of each user trying to authenticate is stored in a List.

  Each state contains this data (in order):
    - Generated Code
    - Origin Socket ID
    - Expiration Time, in seconds.
  """

  use GenServer

  @name __MODULE__
  @expire_interval 30_000

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  # Pushing the user to the state
  def guestlist(sid) do
    GenServer.call(@name, {:guestlist, sid})
  end

  # Seeing if token exists in the state and verifies it.
  def is_cool?(code) do
    GenServer.call(@name, {:is_cool, code})
  end

  # Take codes where [expired?] is true.
  def expire_codes, do: GenServer.call(@name, :expire_codes)

  # Just for development...
  def read_state, do: GenServer.call(@name, :read_state)

  # Callbacks

  @impl true
  def init(state \\ []) do
    :timer.send_interval(@expire_interval, @name, :expire_codes)

    # initializing the state
    {:ok, state}
  end

  # defp expire_tick, do: Process.send_after(@name, :expire_codes, @expire_interval)

  @impl true
  def handle_info(:expire_codes, state) do
    {
      :noreply,
      Enum.filter(
        state,
        fn {_, _, exp} -> expired?(exp) end
      )
    }
  end

  # this is honestly for development so when this is not needed... chuck it!
  @impl true
  def handle_call(:read_state, _from, state), do: {:reply, state, state}

  # Adds a user to the guestlist containing the expiration time, auth code & original session id.
  @impl true
  def handle_call({:guestlist, sid}, _from, state) do
    code = generate_code(sid)
    expires_at = :os.system_time(:seconds) + 1800
    entry = {code, sid, expires_at}
    new_state = [entry | state]

    {:reply, {:ok, code}, new_state}
  end

  @impl true
  def handle_call({:is_cool, code}, _from, state) do
    match =
      state
      |> Enum.filter(fn {_, _, exp} -> !expired?(exp) end)
      |> Enum.find(nil, fn {scode, _sid, _exp} -> scode == code end)

    case match do
      {_code, _sid, _exp} ->
        {:reply, :ok, Enum.filter(state, fn {scode, _, _exp} -> scode != code end)}

      nil ->
        {:reply, {:error, "Verification failed."}, state}
    end
  end

  # Removes codes from the state when the expired time is greater than the system time.
  # @impl true
  # def handle_call(:expire_codes, _from, state) do
  # end

  def expired?(time), do: time > :os.system_time(:seconds)

  def generate_code(salt \\ "crypto") do
    :crypto.hash(:sha256, salt)
    |> Base.encode64()
    |> String.to_charlist()
    |> Enum.shuffle()
    |> Enum.take(6)
    |> :binary.list_to_bin()

    # |> String.upcase()
  end
end

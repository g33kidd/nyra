defmodule Nyra.Bouncer do
  @moduledoc """
  [Bouncer] was created to authenticate a user on Nyra without a password.

  The state of each user trying to authenticate is stored in a List.

  Each state contains this data (in order):
    - Generated Code
    - Origin Socket ID
    - Expiration Time, in seconds.
  """
  use Nyra, :gen_server

  # def start_link(_), do: start_link(__MODULE__, [], name: @name)

  # # Pushing the user to the state
  # def guestlist(sid) do
  #   call(@name, {:guestlist, sid})
  # end

  # # Seeing if token exists in the state and verifies it.
  # def is_cool?(code) do
  #   call(@name, {:is_cool, code})
  # end

  # # Take codes where [expired?] is true.
  # def expire_codes, do: call(@name, :expire_codes)

  # Callbacks

  @impl true
  def init(state \\ []) do
    # :timer.send_interval(@expire_interval, @name, :expire_codes)

    # initializing the state
    {:ok, state}
  end

  @impl true
  def handle_info(:expire_codes, state) do
    filtered_state = Enum.filter(state, fn {_, _, exp} -> expired?(exp) end)
    {:noreply, filtered_state}
  end

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
      |> Enum.filter(fn {_, _, exp} -> not expired?(exp) end)
      |> Enum.find(nil, fn {scode, _sid, _exp} -> scode == code end)

    case match do
      {_code, _sid, _exp} ->
        {:reply, :ok, Enum.filter(state, fn {scode, _, _exp} -> scode != code end)}

      nil ->
        {:reply, {:error, "Verification failed."}, state}
    end
  end

  @spec expired?(Number.t()) :: Number.t()
  def expired?(time), do: time > :os.system_time(:seconds)

  @doc "Generates a mostly random code based on a string given."
  @spec generate_code(String.t()) :: {:ok, String.t()}
  def generate_code(data \\ "crypto") do
    {:ok,
     :crypto.hash(:sha256, data)
     |> Base.encode64()
     |> String.to_charlist()
     |> Enum.shuffle()
     |> Enum.take(6)
     |> :binary.list_to_bin()
     |> String.upcase()}
  end
end

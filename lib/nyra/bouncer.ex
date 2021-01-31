defmodule Nyra.Bouncer do
  use GenServer

  @moduledoc """
  [Bouncer] is the coolest dude around.
  It will generate a randomly generated code for the user to auth with.
  """

  @name __MODULE__
  @expires 120

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  @doc """
  Guestlists a user in the Bouncer application. They will be tested later when they try to enter :)
  """
  def guestlist(sid) do
    GenServer.call(@name, {:guestlist, sid})
  end

  def is_cool?(pid, code) do
    GenServer.call(@name, {:check, pid, code})
  end

  # Callbacks

  @impl true
  def init(state = []) do
    # Removes codes that have been used or not used within the expiration time.
    :timer.send_interval(@expires * 120_000, :expire_codes)

    # initializing the state
    {:ok, state}
  end

  def handle_cast({:guestlist, sid}, state) do
    {:noreply, [{generate_code(sid), sid} | state]}
  end

  def generate_code(salt \\ "crypto") do
    :crypto.hash(:sha256, salt)
    |> Base.encode64()
    |> String.to_charlist()
    |> Enum.shuffle()
    |> Enum.take(6)
    |> :binary.list_to_bin()
    |> String.upcase()
  end
end

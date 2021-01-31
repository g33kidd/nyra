defmodule Nyra.Bouncer do
  use GenServer

  @moduledoc """
  [Bouncer] is the coolest dude around.
  It will generate a randomly generated code for the user to auth with.
  """

  @name __MODULE__
  @expires 120

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def guestlist(sid) do
    GenServer.call(@name, {:guestlist, sid})
  end

  def is_cool?(sid, code) do
    GenServer.call(@name, {:check, sid, code})
  end

  def expire_codes do
    GenServer.call(@name, {:expire_codes, :os.system_time(:seconds)})
  end

  # Callbacks

  @impl true
  def init(state = []) do
    # Removes codes that have been used or not used within the expiration time.
    :timer.send_interval(@expires * 120_000, :expire_codes)

    # initializing the state
    {:ok, state}
  end

  def handle_call({:guestlist, sid}, state) do
    newstate = [{generate_code(sid), sid} | state]
    {:noreply, newstate}
  end

  def handle_call({:check, sid, code}, state) do

      code =

  end
    # with true <- Enum.any?(state, fn u -> {code, sid} == u end) do
    # else
    #   false -> {:reply}
    # end
  # end

  def handle_call({:expire_codes, time}, state) do
    {
      :noreply,
      Enum.filter(state, fn u -> expired?(u, time) end)
    }
  end

  def expired?({_, _, exp}, now), do: exp < now

  def find_code() do
    Enum.
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

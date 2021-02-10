defmodule Bouncer do
  use GenServer

  @name __MODULE__
  @exp_time 60
  @exp_interval 60

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: @name)

  # Methods
  def init(state \\ %{}) do
    :timer.send_interval(@exp_interval, @name, :expire_codes)
  end

  # Callbacks
  def handle_call({:guestlist, email}, from, state) do
    # {:reply, {:ok, code}, state}
  end

  def handle_call({:verify_guest, code}, from, state) do
  end

  def handle_call(:expire_codes, from, state) do
    newstate =
      state
      |> Enum.filter(fn t -> expired?(t) end)
  end

  # Private Methods

  defp expired?(time), do: time > :os.system_time(:seconds)

  # Generates a random 6 character string based on an initial string.
  defp generate_code(salt \\ "crypto") do
    :crypto.hash(:sha256, salt)
    |> Base.encode64()
    |> String.to_charlist()
    |> Enum.shuffle()
    |> Enum.take(6)
    |> :binary.list_to_bin()
    |> String.upcase()
  end
end

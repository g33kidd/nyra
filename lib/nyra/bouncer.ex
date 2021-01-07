defmodule Nyra.Bouncer do
  use GenServer

  @name __MODULE__
  @expires 120

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    :timer.send_interval(@expires * 120_000, :expire_codes)
    :ets.new(@name, [:set, :public, :named_table])
    IO.puts("[info] ETS table for #{@name} was created")
    {:ok, :bouncer_created}
  end

  # This next bit of code should do the following:
  # 1. generate a random 4 digit code.
  # 2. associate code w/ id
  # 3. store in ets with expiry..
  def handle_call({:assign, socket_id}, _, state) do
    code = Enum.random(1_000..9_999)
    IO.inspect(code)
    expiration = :os.system_time(:seconds) + @expires
    :ets.insert(@name, {socket_id, code, expiration})

    {:reply, :ok, state}
  end

  def handle_call(:expire_codes, _, state) do
    IO.inspect(state)
    {:noreply, state}
  end

  def handle_call({:verify, socket_id, input}, _, _) do
    case :ets.lookup(@name, socket_id) do
      [result | rest] ->
        IO.inspect(result)
        IO.inspect(rest)
        {:reply, :ok, validate_coolness(result, input)}

      [] ->
        {:reply, :error, "Invalid code."}
    end
  end

  def expired?(exp), do: exp > :os.system_time(:seconds)

  def validate_coolness({_id, code, expiration}, input) do
    case expired?(expiration) do
      false -> {:ok, String.equivalent?(code, input)}
      true -> :expired
    end
  end

  def assign_code(socket_id) do
    GenServer.call(@name, {:assign, socket_id})
  end

  def check(socket_id, code) do
    GenServer.call(@name, {:verify, socket_id, code})
  end
end

defmodule Bouncer do
  use GenServer

  @name __MODULE__
  @exp_time 60

  # Methods
  def init(state \\ %{}) do
  end

  # Callbacks
  def handle_call(:guestlist, from, state) do
    # {:reply, {:ok, code}, state}
  end

  # Private Methods
end

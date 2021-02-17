defmodule Nyra.UserPool do
  @moduledoc """
  [UserPool] holds a state of chatrooms and keeps track of users.
  """

  use GenServer

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(@name, %{}, name: @name)
  end

  @doc """
  By default we want the state to be a [Map].

  Layout for the state will be as follows:

    %{
      "{chat_identifier}"
    }

  """
  @impl true
  def init(state \\ %{}) do
    :timer.send_interval(30_000, @name, :cleanup)

    {:ok, state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    state
  end
  
  defp cleanup(%{ first | tail }) do
    
  end
end

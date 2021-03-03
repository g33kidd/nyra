defmodule Nyra do
  @moduledoc """
  Nyra keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def gen_server do
    quote do
      use GenServer

      @name __MODULE__

      if Mix.env() == :dev do
        # Reads the state of any GenServer
        def handle_call(:read_state, _from, state), do: {:reply, state, state}

        @doc "Handles reading state for in development."
        def read_state, do: GenServer.call(@name, :read_state)
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

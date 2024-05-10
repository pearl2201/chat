defmodule ChatSocketServer.UserIdCounter do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def value do
    Aget.get(__MODULE__, & &1)
  end

  def increment do
    Agent.get_and_update(__MODULE__, fn state -> {state, state + 1} end)
  end
end

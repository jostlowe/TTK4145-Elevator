defmodule TestHeis.NodeMonitor do
  use GenServer, restart: :permanent
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :net_kernel.monitor_nodes(true)
    {:ok, []}
  end

  def handle_info({:nodedown, node}, _from, state) do
    Logger.warn("Node down! : #{inspect node}")
    {:noreply, state}
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info("Node joined! : #{inspect node}")
    {:noreply, state}
  end

end

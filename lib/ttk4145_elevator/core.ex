defmodule TTK4145Elevator.Core do
  use GenServer, restart: :permanent
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :net_kernel.monitor_nodes(true)
    {:ok, %{orders: %{}, floor: 0}}
  end

  def handle_call({:store_order, order, asignee}, _from, state = %{orders: orders}) do
    Logger.info("Stored order: #{inspect(order)} to #{inspect(asignee)}")
    new_state = %{state | orders: orders |> Map.put(order, asignee)}
    {:reply, :ok, new_state}
  end

  def handle_call({:get_orphaned_orders, dead_node}, _from, state = %{orders: orders}) do
    orphaned_orders =
      orders
      |> Enum.filter(fn {_order, node} -> node == dead_node end)
      |> Enum.map(fn {order, _node} -> order end)

    {:reply, {:ok, orphaned_orders}, state}
  end

  def handle_call({:enter_floor, floor}, _from, state) do
    Logger.info("Entered floor: #{floor}")
    new_state = %{state | floor: floor}
    {:reply, :ok, new_state}
  end

  defp assign_order(order, node) do
    GenServer.multi_call(__MODULE__, {:store_order, order, node})
  end

  def get_orphaned_orders(dead_node) do
    GenServer.call(__MODULE__, {:get_orphaned_orders, dead_node})
  end

  def broker_order(order) do
    assign_order(order, Node.self())
  end

  def enter_floor(floor) do
    GenServer.call(__MODULE__, {:enter_floor, floor})
  end
end

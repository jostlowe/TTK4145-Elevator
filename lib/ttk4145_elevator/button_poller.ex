defmodule TTK4145Elevator.ButtonPoller do
  use Task, restart: :permanent
  require Logger

  alias TTK4145Elevator.{Order, Driver, Core}

  @interval 100

  def child_spec(order) do
    %{id: order, start: {__MODULE__, :start_link, [order]}}
  end

  def start_link(order) do
    Task.start_link(__MODULE__, :run, [order, 0])
  end

  def run(order = %Order{floor: floor, type: type}, previous_state) do
    Process.sleep(@interval)
    state = Driver.get_order_button_state(floor, type)

    case {previous_state, state} do
      {0, 1} ->
        Logger.info("Got button press: #{inspect(order)}")
        Core.broker_order(order)

      _ ->
        :nothing
    end

    run(order, state)
  end
end

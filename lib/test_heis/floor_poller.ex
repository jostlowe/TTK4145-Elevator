defmodule TestHeis.FloorPoller do
  use Task, restart: :permanent
  require Logger

  alias TestHeis.{Driver, Core}

  @interval 100

  def start_link([]) do
    Task.start_link(__MODULE__, :run, [0])
  end

  def run(previous_state) do
    Process.sleep(@interval)
    state = Driver.get_floor_sensor_state()

    case {previous_state, state} do

      {:between_floors, floor} when is_integer(floor) ->
        Core.enter_floor(floor)

      _ ->
        :nothing

    end
    run(state)
  end
end

defmodule TTK4145Elevator.Order do
  defstruct [:floor, :type]

  @max_floor 3
  @valid_order_types [:hall_up, :hall_down, :cab]

  def new(floor, type) when type in @valid_order_types and floor >= 0 do
    %__MODULE__{floor: floor, type: type}
  end

  defp valid_floors(order_type) do
    case order_type do
      :hall_down -> 1..@max_floor
      :hall_up -> 0..(@max_floor - 1)
      :cab -> 0..@max_floor
    end
  end

  defp all_orders(order_type) do
    order_type
    |> valid_floors()
    |> Enum.map(fn floor -> new(floor, order_type) end)
  end

  def all_orders do
    Enum.flat_map(@valid_order_types, &all_orders/1)
  end

  def distance_to_floor(%__MODULE__{floor: order_floor}, floor) when is_integer(floor) do
    abs(order_floor - floor)
  end

  def same_direction?(%__MODULE__{type: type}, travel_direction) do
    case {type, travel_direction} do
      {:cab, _} when type in @valid_order_types -> true
      {type, :up} when type in [:hall_up, :cab] -> true
      {type, :down} when type in [:hall_down, :cab] -> true
      _ -> false
    end
  end

  def priority(order, floor) do
    distance_to_floor(order, floor)
  end
end

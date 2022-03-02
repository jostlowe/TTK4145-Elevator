defmodule TTK4145Elevator.Application do
  alias TTK4145Elevator.{Order, Driver, FloorPoller, Core, ButtonPoller}
  use Application

  def start(_type, _args) do
    topologies = [
      gossip: [
        strategy: Elixir.Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "255.255.255.255",
          broadcast_only: true
        ]
      ]
    ]

    button_pollers =
      for order <- Order.all_orders() do
        {ButtonPoller, order}
      end

    children =
      [
        {Cluster.Supervisor, [topologies, [name: TTK4145Elevator.ClusterSupervisor]]},
        Driver,
        FloorPoller,
        Core
      ] ++ button_pollers

    opts = [strategy: :one_for_one, name: TTK4145Elevator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule TestHeis.Application do
  alias TestHeis.Order
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

    button_pollers = for order <-  Order.all_orders() do
      {TestHeis.ButtonPoller, order}
    end

    children = [
      {Cluster.Supervisor, [topologies, [name: TestHeis.ClusterSupervisor]]},
      TestHeis.Driver,
      TestHeis.FloorPoller,
      TestHeis.Core
    ] ++ button_pollers

    opts = [strategy: :one_for_one, name: TestHeis.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

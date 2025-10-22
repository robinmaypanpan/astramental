class_name HeatFlowGraph
extends Node
# Solve the heat flow problem as an instance of multi-source multi-sink maximum flow problem.
# Represent heat sources as connected to an "omni-source" with flow capacity the heat
# production, and heat sinks as connected to an "omni-sink" with flow capacity equal to
# passive cool off rate. Use Ford-Fulkerson to solve the maximum flow problem.

const HEAT_MAX_FLOW: float = 1e10

var graph: DirectedWeightedGraph

func _ready() -> void:
    graph = DirectedWeightedGraph.new()
    graph.add_vertex("source")
    graph.add_vertex("sink")

func get_neighbors(position: Vector2i):
    return [
        position + Vector2i.RIGHT,
        position + Vector2i.UP,
        position + Vector2i.LEFT,
        position + Vector2i.DOWN,
    ]

func add_building(heat_component: HeatComponent) -> void:
    var heat_building_type = heat_component.heat_building_type
    var position = heat_component.building_entity.position
    graph.add_vertex(position)

    if heat_building_type == Types.HeatBuilding.SOURCE:
        graph.add_edge("source", position, heat_component.heat_production)
        for neighbor_position in get_neighbors(position):
            if graph.has_vertex(neighbor_position):
                graph.add_edge(position, neighbor_position, HEAT_MAX_FLOW)

    elif heat_building_type == Types.HeatBuilding.SINK:
        graph.add_edge(position, "sink", heat_component.heat_passive_cool_off)
        for neighbor_position in get_neighbors(position):
            if graph.has_vertex(neighbor_position):
                graph.add_edge(neighbor_position, position, HEAT_MAX_FLOW)

    else:
        assert(false, "CARRIERS not implemented yet")


func remove_building(heat_component: HeatComponent) -> void:
    var position = heat_component.building_entity.position
    graph.remove_vertex(position)
class_name HeatFlowGraph
extends Node
# Solve the heat flow problem as an instance of multi-source multi-sink maximum flow problem.
# Represent heat sources as connected to an "omni-source" with flow capacity the heat
# production, and heat sinks as connected to an "omni-sink" with flow capacity equal to
# passive cool off rate. Use Ford-Fulkerson to solve the maximum flow problem.

const HEAT_MAX_FLOW: float = 1e10
# define omni-source and omni-sink as vectors so they can be compared to other vectors
const SOURCE := Vector2i(-9, 0)
const SINK := Vector2i(0, -9)

var graph: DirectedWeightedGraph


func _init() -> void:
	graph = DirectedWeightedGraph.new()
	graph.add_vertex(SOURCE)
	graph.add_vertex(SINK)


func get_neighbors(position: Vector2i):
	return [
		position + Vector2i.RIGHT,
		position + Vector2i.UP,
		position + Vector2i.LEFT,
		position + Vector2i.DOWN,
	]


func add_two_way_flow_edge(start, end, weight) -> void:
	## add forward edge and return edge with weight 0 for purposes of Ford-Fulkerson
	graph.add_edge(start, end, weight)
	graph.add_edge(end, start, 0)


func add_building(heat_component: HeatComponent) -> void:
	var heat_building_type = heat_component.heat_building_type
	var position = heat_component.building_entity.position
	graph.add_vertex(position)

	if heat_building_type == Types.HeatBuilding.SOURCE:
		add_two_way_flow_edge(SOURCE, position, heat_component.heat_production)
		for neighbor_position in get_neighbors(position):
			if graph.has_vertex(neighbor_position):
				add_two_way_flow_edge(position, neighbor_position, HEAT_MAX_FLOW)

	elif heat_building_type == Types.HeatBuilding.SINK:
		add_two_way_flow_edge(position, SINK, heat_component.heat_passive_cool_off)
		for neighbor_position in get_neighbors(position):
			if graph.has_vertex(neighbor_position):
				add_two_way_flow_edge(neighbor_position, position, HEAT_MAX_FLOW)

	else:
		assert(false, "CARRIERS not implemented yet")


func remove_building(heat_component: HeatComponent) -> void:
	var position = heat_component.building_entity.position
	graph.remove_vertex(position)


func duplicate_graph() -> HeatFlowGraph:
	var new_graph = DirectedWeightedGraph.new()
	new_graph.edges_out_of = graph.edges_out_of.duplicate(true)
	new_graph.weights = graph.weights.duplicate(true)
	var new_heat_flow_graph = HeatFlowGraph.new()
	new_heat_flow_graph.graph = new_graph
	return new_heat_flow_graph


## Find a path where the forward weights are >= 0 by breadth first search.
func find_augmenting_path() -> Array:
	# do breadth first search
	var vertex_queue: Array = [SOURCE]
	var path_queue: Array[Array] = [[SOURCE]]
	var explored_vertices = []
	while vertex_queue.size() > 0:
		var current_vertex = vertex_queue.pop_back()
		explored_vertices.append(current_vertex)
		var current_path = path_queue.pop_back()
		if current_vertex == HeatFlowGraph.SINK:
			return current_path
		var adjacent_vertices = graph.edges_out_of[current_vertex]
		var edge_weights = graph.weights[current_vertex]
		for i in range(edge_weights.size()):
			var adjacent_vertex = adjacent_vertices[i]
			var edge_weight = edge_weights[i]
			if edge_weight > 0 and not explored_vertices.has(adjacent_vertex):
				vertex_queue.push_front(adjacent_vertex)
				var new_path = current_path.duplicate()
				new_path.append(adjacent_vertex)
				path_queue.push_front(new_path)
	# otherwise, no path found
	return []

func augment_flow_along_path(path: Array):
	# find minimum weight along path
	var min_weight = HEAT_MAX_FLOW
	for i in range(path.size() - 1):
		var start = path[i]
		var end = path[i+1]
		var weight = graph.get_weight(start, end)
		min_weight = min(min_weight, weight)
	# augment flow along path
	for i in range(path.size() - 1):
		print("augmenting flow along path %s, min weight %d" % [path, min_weight])
		var start = path[i]
		var end = path[i+1]
		var forward_weight = graph.get_weight(start, end)
		graph.set_weight(start, end, forward_weight - min_weight)
		var reverse_weight = graph.get_weight(end, start)
		graph.set_weight(end, start, reverse_weight + min_weight)

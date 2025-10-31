class_name HeatFlowGraph
extends Object
## Represent the state of heat buildings and heat flow as a directed weighted graph.

# Solve the heat flow problem as an instance of multi-source multi-sink maximum flow problem.
# Represent heat sources as connected to an "omni-source" with flow capacity the heat
# production, and heat sinks as connected to an "omni-sink" with flow capacity equal to
# passive cool off rate. Use Ford-Fulkerson to solve the maximum flow problem.

## The hard cap on heat flow allowed between buildings.
const HEAT_MAX_FLOW: float = 1e10
# Define omni-source and omni-sink as vectors as that is how other vertices in the graph
# are defined.
# Cannot use -1 because it is technically adjacent to (0, 0) and that isn't desired
## The omni-source.
const SOURCE := Vector2i(-9, 0)

## The omni-sink.
const SINK := Vector2i(0, -9)

## The weighted directed graph used to store the state of the heat flow problem.
## The vertices of the graph are stored as building positions on the grid, as that makes it easier
## to figure out adjacencies.
var graph: DirectedWeightedGraph

## Store a map to convert vertex positions to their corresponding heat components.
var vertex_to_component_map: Dictionary[Vector2i, HeatComponent]

## List of all heat sources.
var heat_sources: Array[HeatComponent]

## List of overheated heat sources.
var overheated_heat_sources: Array[HeatComponent]

## List of all heat sinks.
var heat_sinks: Array[HeatComponent]


# TODO: there has to be a better way to do this than manually adding new attributes every time
# this has to be updated.
## Do a deep copy of this object and return the duplicate.
func duplicate_graph() -> HeatFlowGraph:
	var new_heat_flow_graph: HeatFlowGraph = HeatFlowGraph.new()

	var new_graph: DirectedWeightedGraph = DirectedWeightedGraph.new()
	new_graph.edges_out_of = graph.edges_out_of.duplicate(true)
	new_graph.weights = graph.weights.duplicate(true)
	new_heat_flow_graph.graph = new_graph

	new_heat_flow_graph.vertex_to_component_map = vertex_to_component_map.duplicate()

	new_heat_flow_graph.heat_sources = heat_sources.duplicate()
	new_heat_flow_graph.overheated_heat_sources = overheated_heat_sources.duplicate()
	new_heat_flow_graph.heat_sinks = heat_sinks.duplicate()

	return new_heat_flow_graph


## Create a new heat flow graph containing only the omni-source and omni-sink.
func _init() -> void:
	graph = DirectedWeightedGraph.new()
	graph.add_vertex(SOURCE)
	graph.add_vertex(SINK)


## Given a position, give the 4 positions that are cardinally adjacent to that position.
## Used internally to figure out adjacencies.
func _get_neighbors(position: Vector2i):
	return [
		position + Vector2i.RIGHT,
		position + Vector2i.UP,
		position + Vector2i.LEFT,
		position + Vector2i.DOWN,
	]


## Add one edge with start -> end with the given weight, and another edge end -> start with weight
## 0. This is needed to make running Ford-Fulkerson easier.
func _add_two_way_flow_edge(start, end, weight) -> void:
	graph.add_edge(start, end, weight)
	graph.add_edge(end, start, 0)


## Given a heat component, add that building to the heat flow graph.
## If it is a source or sink, connect it to the omni-source/omni-sink.
## If it is adjacent to any buildings already in the heat flow graph,
## add edges flowing out of the source or into the sink.
func add_building(heat_component: HeatComponent) -> void:
	var position: Vector2i = heat_component.building_entity.position
	var update_interval = Globals.settings.update_interval
	graph.add_vertex(position)
	vertex_to_component_map[position] = heat_component

	if heat_component.is_source:
		heat_sources.append(heat_component)
		# omni-source -> source
		var weight = heat_component.heat_production * update_interval
		_add_two_way_flow_edge(SOURCE, position, weight)
		for neighbor_position: Vector2i in _get_neighbors(position):
			if graph.has_vertex(neighbor_position):
				# source -> neighbors
				_add_two_way_flow_edge(position, neighbor_position, HEAT_MAX_FLOW)

	elif heat_component.is_sink:
		heat_sinks.append(heat_component)
		# sink -> omni-sink
		var weight = heat_component.heat_passive_cool_off * update_interval
		_add_two_way_flow_edge(position, SINK, weight)
		for neighbor_position: Vector2i in _get_neighbors(position):
			if graph.has_vertex(neighbor_position):
				# neighbors -> sink
				_add_two_way_flow_edge(neighbor_position, position, HEAT_MAX_FLOW)

	else:
		assert(false, "CARRIERS not implemented yet")


## Given a heat component, remove that building from the heat flow graph.
func remove_building(heat_component: HeatComponent) -> void:
	if heat_component.is_source:
		heat_sources.erase(heat_component)
	elif heat_component.is_sink:
		heat_sinks.erase(heat_component)

	var position: Vector2i = heat_component.building_entity.position
	graph.remove_vertex(position)
	vertex_to_component_map.erase(position)


## Set a building to the overheated state and disconnect it from the omni-source.
func set_building_overheated(heat_source: HeatComponent) -> void:
	heat_source.heat_state = Types.HeatState.OVERHEATED
	overheated_heat_sources.append(heat_source)
	heat_sources.erase(heat_source)

	var grid_position = heat_source.building_entity.position
	graph.set_weight(SOURCE, grid_position, 0.0)


## Set a building to the running state and reconnect it to the omni-source.
func set_building_running(heat_source: HeatComponent) -> void:
	heat_source.heat_state = Types.HeatState.RUNNING
	heat_sources.append(heat_source)
	overheated_heat_sources.erase(heat_source)

	var grid_position = heat_source.building_entity.position
	var update_interval = Globals.settings.update_interval
	var heating_weight = heat_source.heat_production * update_interval
	graph.set_weight(SOURCE, grid_position, heating_weight)


## Given a vertex in the graph, get its corresponding heat component.
## Return null if there isn't one.
func get_component_at(position: Vector2i) -> HeatComponent:
	return vertex_to_component_map.get(position)


## Adjust weights out of the omni-source to account for energy satisfaction making buildings
## produce less heat.
func adjust_weights_for_energy_satisfaction(energy_satisfaction: float) -> void:
	var source_edge_weights = graph.weights[SOURCE as Variant]
	for i in range(source_edge_weights.size()):
		source_edge_weights[i] = source_edge_weights[i] * energy_satisfaction


## Find a path from omni-source to omni-sink where the forward weights are >= 0
## by breadth first search. Part of the Ford-Fulkerson algorithm.
func find_augmenting_path() -> Array:
	# do breadth first search
	var vertex_queue: Array[Variant] = [SOURCE]
	var path_queue: Array[Array] = [[SOURCE]]
	var explored_vertices: Array[Variant] = []
	while vertex_queue.size() > 0:
		var current_vertex: Variant = vertex_queue.pop_back()
		explored_vertices.append(current_vertex)
		var current_path: Array = path_queue.pop_back()

		if current_vertex == HeatFlowGraph.SINK:
			return current_path

		var adjacent_vertices: Array[Variant] = graph.edges_out_of[current_vertex]
		var edge_weights: Array = graph.weights[current_vertex]
		for i in range(edge_weights.size()):
			var adjacent_vertex: Variant = adjacent_vertices[i]
			var edge_weight: float = edge_weights[i]
			if edge_weight > 0 and not explored_vertices.has(adjacent_vertex):
				vertex_queue.push_front(adjacent_vertex)
				var new_path: Array[Variant] = current_path.duplicate()
				new_path.append(adjacent_vertex)
				path_queue.push_front(new_path)
	# otherwise, no path found
	return []


## Given a path from omni-source to omni-sink, augment the flow along that path by the minimum of
## weights along that path. This reduces the forward flow by the min and increases the reverse flow
## by the min. Part of the Ford-Fulkerson algorithm.
func augment_flow_along_path(path: Array[Variant]):
	# find minimum weight along path
	var min_weight: float = HEAT_MAX_FLOW
	for i in range(path.size() - 1):
		var start: Variant = path[i]
		var end: Variant = path[i + 1]
		var weight: float = graph.get_weight(start, end)
		min_weight = min(min_weight, weight)
	# augment flow along path
	print("augmenting flow along path %s, min weight %f" % [path, min_weight])
	for i in range(path.size() - 1):
		var start: Variant = path[i]
		var end: Variant = path[i + 1]
		var forward_weight: float = graph.get_weight(start, end)
		graph.set_weight(start, end, forward_weight - min_weight)
		var reverse_weight: float = graph.get_weight(end, start)
		graph.set_weight(end, start, reverse_weight + min_weight)

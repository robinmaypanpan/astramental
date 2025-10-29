class_name HeatSystem
extends Node
## Maintains and updates the heat of all buildings.

## Represents the heat flow relationships between the heat buildings.
## Is the starting point for the Ford-Fulkerson algorithm.
var heat_flow_graphs: Dictionary[int, HeatFlowGraph]

## Represents the most up to date version of the heat flow graphs.
## Becomes the current heat flow graph every update.
var heat_flow_graphs_current: Dictionary[int, HeatFlowGraph]

## Whether the heat flow graphs have been changed this frame.
var heat_flow_graphs_dirty: Dictionary[int, bool]

## Represents the steady state flow of heat as the application of the Ford-Fulkerson algorithm
## to the heat flow graph.
## The ending state of this algorithm is as follows:
## weight from omni-source -> source: excess heat produced by building
## weight from source -> omni-source: consumed heat flow from sinks
## weight from omni-sink -> sink: unused cooling from building
## weight from sink -> omni-sink: consumed heat flow from sources
var steady_state_flows: Dictionary[int, HeatFlowGraph]

func _ready() -> void:
	ComponentManager.component_added.connect(on_component_added)
	ComponentManager.component_removed.connect(on_component_removed)
	Model.game_ready.connect(on_game_ready)


## When a heat component is added, update the internal state and re-calculate the steady state
## flow of heat.
func on_component_added(component: BuildingComponent) -> void:
	if component is not HeatComponent:
		return

	var player_id: int = component.building_entity.player_id

	heat_flow_graphs_current[player_id].add_building(component)
	heat_flow_graphs_dirty[player_id] = true

	Model.add_heat_data_at.rpc(
		component.building_entity.player_id,
		component.building_entity.position,
		component.heat,
		component.heat_capacity)


## When a heat component is removed, update the internal state and re-calculate the steady state
## flow of heat.
func on_component_removed(component: BuildingComponent) -> void:
	if component is not HeatComponent:
		return

	var player_id: int = component.building_entity.player_id

	heat_flow_graphs_current[player_id].remove_building(component)
	heat_flow_graphs_dirty[player_id] = true

	Model.remove_heat_data_at.rpc(
		player_id,
		component.building_entity.position)


## When game is ready, initialize starting state of heat system.
func on_game_ready() -> void:
	for player_id: int in ConnectionSystem.get_player_id_list():
		heat_flow_graphs[player_id] = HeatFlowGraph.new()
		heat_flow_graphs_current[player_id] = HeatFlowGraph.new()
		steady_state_flows[player_id] = HeatFlowGraph.new()
		heat_flow_graphs_dirty[player_id] = false


## Use the Ford-Fulkerson algorithm to calculate the steady state flow of heat.
## Algorithm reference: https://brilliant.org/wiki/ford-fulkerson-algorithm/
func calculate_steady_state_flow(player_id: int) -> void:
	var heat_flow_graph: HeatFlowGraph = heat_flow_graphs[player_id]
	steady_state_flows[player_id] = heat_flow_graph.duplicate_graph()
	var augmenting_path: Array = steady_state_flows[player_id].find_augmenting_path()
	while augmenting_path != []:
		steady_state_flows[player_id].augment_flow_along_path(augmenting_path)
		augmenting_path = steady_state_flows[player_id].find_augmenting_path()


## Get the excess heat production for the source at the given position.
func get_excess_heat_production_at(player_id: int, position: Vector2i) -> float:
	return steady_state_flows[player_id].graph.get_weight(HeatFlowGraph.SOURCE, position)


## Get the spare cooling rate for the sink at the given position.
func get_spare_cooling_at(player_id: int, position: Vector2i) -> float:
	return steady_state_flows[player_id].graph.get_weight(position, HeatFlowGraph.SINK)


## Debug function for printing the flow rates for all sources and sinks.
func print_flow_rates() -> void:
	var heat_components: Array = ComponentManager.get_components("HeatComponent")
	for heat_component: HeatComponent in heat_components:
		if heat_component.is_source:
			var heat_production: float = heat_component.heat_production
			var position: Vector2i = heat_component.building_entity.position
			var player_id: int = heat_component.building_entity.player_id
			var heat_graph: DirectedWeightedGraph = steady_state_flows[player_id].graph
			var heat_consumed: float = heat_graph.get_weight(position, HeatFlowGraph.SOURCE)
			print("heat component at %s: %d/%d" % [position, heat_consumed, heat_production])
		elif heat_component.is_sink:
			var heat_passive_cool_off: float = heat_component.heat_passive_cool_off
			var position: Vector2i = heat_component.building_entity.position
			var player_id: int = heat_component.building_entity.player_id
			var heat_graph: DirectedWeightedGraph = steady_state_flows[player_id].graph
			var heat_consumed: float = heat_graph.get_weight(HeatFlowGraph.SINK, position)
			print("heat component at %s: %d/%d" % [position, heat_consumed, heat_passive_cool_off])


## Set the heat in the component and in the model to the specified heat.
func set_heat(heat_component: HeatComponent, new_heat: float) -> void:
	heat_component.heat = new_heat
	var player_id = heat_component.building_entity.player_id
	var position = heat_component.building_entity.position
	Model.set_heat_to.rpc(player_id, position, new_heat)


## Given a position, find all buildings next to that position with heat in them.
func find_adjacent_buildings_with_heat(player_id: int, position: Vector2i) -> Array[HeatComponent]:
	var buildings_with_heat: Array[HeatComponent] = []
	var adjacent_vertices: Array = heat_flow_graphs[player_id].graph.edges_out_of[position as Variant]
	for adjacent_vertex: Vector2i in adjacent_vertices:
		var heat_component = heat_flow_graphs[player_id].get_component_at(adjacent_vertex)
		if heat_component and heat_component.heat > 0:
			buildings_with_heat.append(heat_component)
	return buildings_with_heat


## Given a list of buildings and available cooling, cool off the hottest building. If there is
## a tie, cool off all hottest buildings evenly.
func cool_off_hottest_building(buildings: Array[HeatComponent], spare_cooling: float) -> float:
	if buildings.is_empty():
		return 0.0
	# we actually have buildings to cool, so sort by heat, descending
	buildings.sort_custom(func(c1, c2): return c1.heat > c2.heat)
	var index: int = 0
	var total_cooling_done: float = 0.0
	while not is_zero_approx(spare_cooling):
		var hottest_building_heat: float = buildings[index].heat
		if is_zero_approx(hottest_building_heat):
			break # nothing left to cool down
		var next_hottest_building_heat: float
		if index < buildings.size() - 1:
			next_hottest_building_heat = buildings[index + 1].heat
		else:
			next_hottest_building_heat = 0.0 # we went through all the buildings, cool to 0
		var num_buildings_to_cool: int = index + 1
		# cool down all buildings to cool to the next hottest building heat
		var cool_amount = hottest_building_heat - next_hottest_building_heat
		var required_heat: float = num_buildings_to_cool * cool_amount
		if required_heat <= spare_cooling:
			# we have enough cooling? cool the buildings
			spare_cooling -= required_heat
			total_cooling_done += required_heat
		else:
			# we don't have enough cooling? cool evenly
			cool_amount = spare_cooling / num_buildings_to_cool
			total_cooling_done += spare_cooling
			spare_cooling = 0.0
		# actually cool all the buildings
		for i in range(num_buildings_to_cool):
			set_heat(buildings[i], buildings[i].heat - cool_amount)
		# either we are out of cooling and the loop breaks or cool off one more building than we
		# were previously, which is now the same temp as last building
		index += 1
		# still have spare cooling but we are out of buildings to cool
		if index == buildings.size():
			break

	return total_cooling_done


## Update all heat buildings based on the steady state flow of heat.
func update() -> void:
	for player_id: int in ConnectionSystem.get_player_id_list():
		# was this updated this frame? if so, update our heat flow graph to the current one
		if heat_flow_graphs_dirty[player_id]:
			heat_flow_graphs[player_id] = heat_flow_graphs_current[player_id].duplicate_graph()
			heat_flow_graphs_dirty[player_id] = false
			calculate_steady_state_flow(player_id)
			# debug info
			if OS.is_debug_build():
				print_flow_rates()

		var heat_flow_graph: HeatFlowGraph = heat_flow_graphs[player_id]
		# heat each source up by the excess heat production the steady state says
		for heat_source: HeatComponent in heat_flow_graph.heat_sources:
			var position: Vector2i = heat_source.building_entity.position
			var heat_generated_per_sec: float = get_excess_heat_production_at(player_id, position)
			if heat_generated_per_sec > 0:
				var update_interval: float = Globals.settings.update_interval
				# heat generation is affected by energy
				var energy_satisfaction: float = Model.get_energy_satisfaction(player_id)
				var heat_generated_this_tick: float = (
					heat_generated_per_sec * update_interval * energy_satisfaction
				)
				var current_heat: float = heat_source.heat
				var new_heat: float = min(
					current_heat + heat_generated_this_tick,
					heat_source.heat_capacity)
				set_heat(heat_source, new_heat)

		# if a sink has excess cooling, find buildings with heat in them and cool them off
		for heat_sink: HeatComponent in heat_flow_graph.heat_sinks:
			# setting position to Vector2i gives an error
			var position: Variant = heat_sink.building_entity.position
			var spare_cooling_per_sec: float = get_spare_cooling_at(player_id, position)
			var update_interval: float = Globals.settings.update_interval
			# cooling is independent of energy
			var spare_cooling_this_tick: float = spare_cooling_per_sec * update_interval
			var spare_heat_capacity: float = heat_sink.heat_capacity - heat_sink.heat
			var total_capacity_cooling: float = spare_cooling_this_tick + spare_heat_capacity
			if total_capacity_cooling > 0:
				# find buildings next to this one with excess heat to cool off
				var buildings_to_cool: Array[HeatComponent] = (
					find_adjacent_buildings_with_heat(player_id, position)
				)
				# cool off the hottest building
				var total_heat_pulled: float = cool_off_hottest_building(
					buildings_to_cool, total_capacity_cooling)
				var net_heat_change = total_heat_pulled - spare_cooling_this_tick
				var new_heat = max(heat_sink.heat + net_heat_change, 0.0)
				set_heat(heat_sink, new_heat)

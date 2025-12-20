class_name NewHeatSystem
extends BuildingComponentSystem
## Maintains and updates the heat of all buildings.

## Represents the heat flow relationships between the heat buildings.
## Is the starting point for the Ford-Fulkerson algorithm.
var heat_flow_graph: HeatFlowGraph

## Represents the most up to date version of the heat flow graphs.
## Becomes the current heat flow graph every update.
var heat_flow_graph_current: HeatFlowGraph

## Whether the heat flow graphs have been changed this frame.
var heat_flow_graph_dirty: bool

## Represents the steady state flow of heat as the application of the Ford-Fulkerson algorithm
## to the heat flow graph.
## The ending state of this algorithm is as follows:
## weight from omni-source -> source: excess heat produced by building
## weight from source -> omni-source: consumed heat flow from sinks
## weight from omni-sink -> sink: unused cooling from building
## weight from sink -> omni-sink: consumed heat flow from sources
var steady_state_flow: HeatFlowGraph


func _ready() -> void:
	component_manager.component_added.connect(on_component_added)
	component_manager.component_removed.connect(on_component_removed)
	Model.game_ready.connect(on_game_ready)


## When a heat component is added, update the internal state.
func on_component_added(component: BuildingComponent) -> void:
	if component is not HeatComponent:
		return

	heat_flow_graph_current.add_building(component)
	heat_flow_graph_dirty = true

	player_state.building_heat.add(
		HeatData.new(
			component.building_entity.position,
			component.heat,
			component.heat_capacity,
			component.heat_state
		)
	)


## When a heat component is removed, update the internal state.
func on_component_removed(component: BuildingComponent) -> void:
	if component is not HeatComponent:
		return

	heat_flow_graph_current.remove_building(component)
	heat_flow_graph_dirty = true

	player_state.building_heat.remove_at_pos(component.building_entity.position)


## When game is ready, initialize starting state of heat system.
func on_game_ready() -> void:
	heat_flow_graph = HeatFlowGraph.new()
	heat_flow_graph_current = HeatFlowGraph.new()
	steady_state_flow = HeatFlowGraph.new()
	heat_flow_graph_dirty = false

	var player_states: PlayerStates = Model.player_states
	player_states.energy_satisfaction_changed.connect(on_energy_satisfaction_changed)


## When energy satisfaction is changed, set heat flow graphs to dirty to recalc with new energy
## satisfaction.
func on_energy_satisfaction_changed(_player_id: int, _new_energy_satisfaction: float):
	heat_flow_graph_dirty = true


## Use the Ford-Fulkerson algorithm to calculate the steady state flow of heat.
## Algorithm reference: https://brilliant.org/wiki/ford-fulkerson-algorithm/
func calculate_steady_state_flow() -> void:
	steady_state_flow = heat_flow_graph.duplicate_graph()
	var energy_satisfaction: float = player_state.energy_satisfaction
	steady_state_flow.adjust_weights_for_energy_satisfaction(energy_satisfaction)
	var augmenting_path: Array = steady_state_flow.find_augmenting_path()
	while augmenting_path != []:
		steady_state_flow.augment_flow_along_path(augmenting_path)
		augmenting_path = steady_state_flow.find_augmenting_path()


## Get the excess heat production for the source at the given position.
func get_excess_heat_production_at(position: Vector2i) -> float:
	return steady_state_flow.graph.get_weight(HeatFlowGraph.SOURCE, position)


## Get the spare cooling rate for the sink at the given position.
func get_spare_cooling_at(position: Vector2i) -> float:
	return steady_state_flow.graph.get_weight(position, HeatFlowGraph.SINK)


## Debug function for printing the flow rates for all sources and sinks.
func print_flow_rates() -> void:
	var heat_components: Array = ComponentManager.get_components("HeatComponent")
	for heat_component: HeatComponent in heat_components:
		if heat_component.is_source:
			var heat_production: float = (
				heat_component.heat_production * Globals.settings.update_interval
			)
			var position: Vector2i = heat_component.building_entity.position
			var heat_graph: DirectedWeightedGraph = steady_state_flow.graph
			var heat_consumed: float = heat_graph.get_weight(position, HeatFlowGraph.SOURCE)
			print("heat component at %s: %f/%f" % [position, heat_consumed, heat_production])
		elif heat_component.is_sink:
			var heat_passive_cool_off: float = (
				heat_component.heat_passive_cool_off * Globals.settings.update_interval
			)
			var position: Vector2i = heat_component.building_entity.position
			var heat_graph: DirectedWeightedGraph = steady_state_flow.graph
			var heat_consumed: float = heat_graph.get_weight(HeatFlowGraph.SINK, position)
			print("heat component at %s: %f/%f" % [position, heat_consumed, heat_passive_cool_off])


## Set the heat in the component and in the model to the specified heat.
func set_heat(heat_component: HeatComponent, new_heat: float) -> void:
	heat_component.heat = new_heat
	var grid_position: Vector2i = heat_component.building_entity.position
	player_state.building_heat.set_heat(grid_position, new_heat)


## Given a position, find all buildings next to that position with heat in them.
func find_adjacent_buildings_with_heat(grid_position: Vector2i) -> Array[HeatComponent]:
	var buildings_with_heat: Array[HeatComponent] = []
	var adjacent_vertices: Array = heat_flow_graph.graph.edges_out_of[grid_position as Variant]
	for adjacent_vertex: Vector2i in adjacent_vertices:
		var heat_component: HeatComponent = heat_flow_graph.get_component_at(adjacent_vertex)
		if heat_component and heat_component.heat > 0:
			buildings_with_heat.append(heat_component)
	return buildings_with_heat


## Given a list of buildings and available cooling, cool off the hottest building. If there is
## a tie, cool off all hottest buildings evenly. Return the amount of cooling done.
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
			break  # nothing left to cool down
		var next_hottest_building_heat: float
		if index < buildings.size() - 1:
			next_hottest_building_heat = buildings[index + 1].heat
		else:
			next_hottest_building_heat = 0.0  # we went through all the buildings, cool to 0
		var num_buildings_to_cool: int = index + 1
		# cool down all buildings to cool to the next hottest building heat
		var cool_amount: float = hottest_building_heat - next_hottest_building_heat
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
		# still have spare cooling but we are out of buildings to cool? we're done
		if index == buildings.size():
			break

	return total_cooling_done


## Update all heat buildings based on the steady state flow of heat.
func update() -> void:
	# was this updated this frame? if so, update our heat flow graph to the current one
	if heat_flow_graph_dirty:
		heat_flow_graph = heat_flow_graph_current.duplicate_graph()
		heat_flow_graph_dirty = false
		calculate_steady_state_flow()
		# debug info
		if OS.is_debug_build():
			print_flow_rates()

	# heat each source up by the excess heat production the steady state says

	for heat_source: HeatComponent in heat_flow_graph.heat_sources:
		var position: Vector2i = heat_source.building_entity.position
		var heat_generated_this_tick: float = get_excess_heat_production_at(position)
		if heat_generated_this_tick > 0:
			var current_heat: float = heat_source.heat
			var new_heat: float = current_heat + heat_generated_this_tick
			set_heat(heat_source, new_heat)

	# if a sink has excess cooling, find buildings with heat in them and cool them off
	for heat_sink: HeatComponent in heat_flow_graph.heat_sinks:
		var position: Vector2i = heat_sink.building_entity.position
		var spare_cooling_this_tick: float = get_spare_cooling_at(position)
		var spare_heat_capacity: float = heat_sink.heat_capacity - heat_sink.heat
		var total_capacity_cooling: float = spare_cooling_this_tick + spare_heat_capacity
		if total_capacity_cooling > 0:
			# find buildings next to this one with excess heat to cool off
			var buildings_to_cool: Array[HeatComponent] = find_adjacent_buildings_with_heat(
				position
			)
			# cool off the hottest building
			var total_heat_pulled: float = cool_off_hottest_building(
				buildings_to_cool, total_capacity_cooling
			)
			var net_heat_change: float = total_heat_pulled - spare_cooling_this_tick
			var new_heat: float = max(heat_sink.heat + net_heat_change, 0.0)
			set_heat(heat_sink, new_heat)

	# overheated heat sources just cool down as much as they can
	for overheated_source: HeatComponent in heat_flow_graph.overheated_heat_sources:
		var update_interval: float = Globals.settings.update_interval
		var cooling_this_tick: float = overheated_source.heat_passive_cool_off * update_interval
		var new_heat: float = overheated_source.heat - cooling_this_tick
		set_heat(overheated_source, new_heat)

	# check if buildings are overheated/not overheated
	for heat_source: HeatComponent in heat_flow_graph.heat_sources:
		if (
			heat_source.heat > heat_source.heat_capacity
			or is_equal_approx(heat_source.heat, heat_source.heat_capacity)
		):
			heat_source.heat = heat_source.heat_capacity
			heat_flow_graph_current.set_building_overheated(heat_source)
			heat_flow_graph_dirty = true
			player_state.building_heat.set_heat_state(
				heat_source.building_entity.position, Types.HeatState.OVERHEATED
			)

	for overheated_source: HeatComponent in heat_flow_graph.overheated_heat_sources:
		if overheated_source.heat < 0.0 or is_zero_approx(overheated_source.heat):
			overheated_source.heat = 0.0
			heat_flow_graph_current.set_building_running(overheated_source)
			heat_flow_graph_dirty = true
			player_state.building_heat.set_heat_state(
				overheated_source.building_entity.position, Types.HeatState.RUNNING
			)

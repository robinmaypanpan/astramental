class_name HeatSystem
extends Node
## Maintains and updates the heat of all buildings.

## Represents the heat flow relationships between the heat buildings.
## Is the starting point for the Ford-Fulkerson algorithm.
var heat_flow_graphs: Dictionary[int, HeatFlowGraph]

## Represents the steady state flow of heat as the application of the Ford-Fulkerson algorithm
## to the heat flow graph.
## The ending state of this algorithm is as follows:
## weight from omni-source -> source: excess heat produced by building
## weight from source -> omni-source: consumed heat flow from sinks
## weight from omni-sink -> sink: unused cooling from building
## weight from sink -> omni-sink: consumed heat flow from sources
var steady_state_flows: Dictionary[int, HeatFlowGraph]

## List of all heat sources.
var heat_sources: Dictionary[int, Array]

## List of all heat sinks.
var heat_sinks: Dictionary[int, Array]

func _ready() -> void:
	ComponentManager.component_added.connect(_on_component_added)
	ComponentManager.component_removed.connect(_on_component_removed)
	Model.game_ready.connect(_on_game_ready)


## When a heat component is added, update the internal state and re-calculate the steady state
## flow of heat.
func _on_component_added(component: BuildingComponent) -> void:
	if component is HeatComponent:
		var player_id: int = component.building_entity.player_id

		heat_flow_graphs[player_id].add_building(component)

		if component.is_source:
			heat_sources[player_id].append(component)
		elif component.is_sink:
			heat_sinks[player_id].append(component)

		Model.add_heat_data_at.rpc(
			component.building_entity.player_id,
			component.building_entity.position,
			component.heat,
			component.heat_capacity)

		calculate_steady_state_flow(player_id)

		print_flow_rates()


## When a heat component is removed, update the internal state and re-calculate the steady state
## flow of heat.
func _on_component_removed(component: BuildingComponent) -> void:
	if component is HeatComponent:
		var player_id: int = component.building_entity.player_id

		if component.is_source:
			heat_sources.erase(component)
		elif component.is_sink:
			heat_sinks.erase(component)

		heat_flow_graphs[player_id].remove_building(component)

		Model.remove_heat_data_at.rpc(
			player_id,
			component.building_entity.position)

		calculate_steady_state_flow(player_id)

		print_flow_rates()


## When game is ready, initialize starting state of heat system.
func _on_game_ready() -> void:
	for player_id: int in ConnectionSystem.get_player_id_list():
		heat_flow_graphs[player_id] = HeatFlowGraph.new()
		steady_state_flows[player_id] = HeatFlowGraph.new()
		heat_sources[player_id] = []
		heat_sinks[player_id] = []


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


## Given a list of buildings and available cooling, cool off the hottest building. If there is
## a tie, cool off all hottest buildings evenly.
func cool_off_hottest_building(buildings: Array[HeatComponent], spare_cooling: float) -> void:
	# sort by heat, descending
	buildings.sort_custom(func(c1, c2): return c1.heat > c2.heat)
	var index = 0
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
		else:
			# we don't have enough cooling? cool evenly
			cool_amount = spare_cooling / num_buildings_to_cool
			spare_cooling = 0.0
		# actually cool all the buildings
		for i in range(num_buildings_to_cool):
			set_heat(buildings[i], buildings[i].heat - cool_amount)
		# cool off one more building than we were previously,
		# which is now the same temp as last building or the loop is about to break
		index += 1


## Update all heat buildings based on the steady state flow of heat.
func update() -> void:
	for player_id: int in ConnectionSystem.get_player_id_list():
		# heat each source up by the excess heat production the steady state says
		for heat_source: HeatComponent in heat_sources[player_id]:
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
		for heat_sink: HeatComponent in heat_sinks[player_id]:
			# NOTE: Assigning position as Vector2i here causes a type mismatch error
			# when accessing edges_out_of[position], so it must be Variant.
			var position: Variant = heat_sink.building_entity.position
			var spare_cooling_per_sec: float = get_spare_cooling_at(player_id, position)
			if spare_cooling_per_sec > 0:
				var update_interval: float = Globals.settings.update_interval
				# cooling is independent of energy
				var spare_cooling_this_tick: float = spare_cooling_per_sec * update_interval
				# find buildings next to this one with excess heat to cool off
				var buildings_to_cool: Array[HeatComponent] = []
				var adjacent_vertices: Array = heat_flow_graphs[player_id].graph.edges_out_of[position]
				for adjacent_vertex: Vector2i in adjacent_vertices:
					var heat_component = heat_flow_graphs[player_id].get_component_at(adjacent_vertex)
					if heat_component and heat_component.heat > 0:
						buildings_to_cool.append(heat_component)
				# cool off the hottest building
				if buildings_to_cool != []:
					cool_off_hottest_building(buildings_to_cool, spare_cooling_this_tick)

class_name HeatSystem
extends Node

# TODO: construct HeatFlowGraph per player
var heat_flow_graph: HeatFlowGraph

var steady_state_flow: HeatFlowGraph

var heat_sources: Array[HeatComponent]

var heat_sinks: Array[HeatComponent]

func _ready() -> void:
	heat_flow_graph = HeatFlowGraph.new()
	steady_state_flow = heat_flow_graph.duplicate_graph()
	ComponentManager.component_added.connect(_on_component_added)
	ComponentManager.component_removed.connect(_on_component_removed)

func _on_component_added(component: BuildingComponent) -> void:
	if component is HeatComponent:
		heat_flow_graph.add_building(component)
		if component.is_source:
			heat_sources.append(component)
		elif component.is_sink:
			heat_sinks.append(component)
		Model.add_heat_data_at(
			component.building_entity.player_id,
			component.building_entity.position,
			component.heat,
			component.heat_capacity)
		calculate_steady_state_flow()
		print_flow_rates()

func _on_component_removed(component: BuildingComponent) -> void:
	if component is HeatComponent:
		if component.is_source:
			heat_sources.erase(component)
		elif component.is_sink:
			heat_sinks.erase(component)
		heat_flow_graph.remove_building(component)
		Model.remove_heat_data_at(
			component.building_entity.player_id,
			component.building_entity.position)
		calculate_steady_state_flow()
		print_flow_rates()

func calculate_steady_state_flow() -> void:
	steady_state_flow = heat_flow_graph.duplicate_graph()
	var augmenting_path = steady_state_flow.find_augmenting_path()
	while augmenting_path != []:
		steady_state_flow.augment_flow_along_path(augmenting_path)
		augmenting_path = steady_state_flow.find_augmenting_path()

func get_excess_heat_production_at(position: Vector2i) -> float:
	return steady_state_flow.graph.get_weight(HeatFlowGraph.SOURCE, position)

func get_spare_cooling_at(position: Vector2i) -> float:
	return steady_state_flow.graph.get_weight(position, HeatFlowGraph.SINK)

func print_flow_rates() -> void:
	var heat_components = ComponentManager.get_components("HeatComponent")
	for heat_component: HeatComponent in heat_components:
		if heat_component.heat_building_type == Types.HeatBuilding.SOURCE:
			var heat_production = heat_component.heat_production
			var position = heat_component.building_entity.position
			var heat_consumed = steady_state_flow.graph.get_weight(position, HeatFlowGraph.SOURCE)
			print("heat component at %s: %d/%d" % [position, heat_consumed, heat_production])
		elif heat_component.heat_building_type == Types.HeatBuilding.SINK:
			var heat_passive_cool_off = heat_component.heat_passive_cool_off
			var position = heat_component.building_entity.position
			var heat_consumed = steady_state_flow.graph.get_weight(HeatFlowGraph.SINK, position)
			print("heat component at %s: %d/%d" % [position, heat_consumed, heat_passive_cool_off])

func update() -> void:
	for heat_source: HeatComponent in heat_sources:
		var position = heat_source.building_entity.position
		var heat_generated_per_sec = get_excess_heat_production_at(position)
		if heat_generated_per_sec > 0:
			var update_interval = Globals.settings.update_interval
			var heat_generated_this_tick = heat_generated_per_sec * update_interval
			var current_heat = heat_source.heat
			heat_source.heat = min(
				current_heat + heat_generated_this_tick,
				heat_source.heat_capacity)
			Model.set_heat_to(
				heat_source.building_entity.player_id,
				position,
				heat_source.heat)

	for heat_sink: HeatComponent in heat_sinks:
		var position: Variant = heat_sink.building_entity.position
		var spare_cooling_per_sec = get_spare_cooling_at(position)
		if spare_cooling_per_sec > 0:
			var update_interval = Globals.settings.update_interval
			var spare_cooling_this_tick = spare_cooling_per_sec * update_interval
			# find buildings next to this one with excess heat to cool off
			var buildings_to_cool_off = []
			var adjacent_vertices = heat_flow_graph.graph.edges_out_of[position]
			for adjacent_vertex in adjacent_vertices:
				var heat_component = heat_flow_graph.get_component_at(adjacent_vertex)
				if heat_component and heat_component.heat > 0:
					buildings_to_cool_off.append(heat_component)
			# evenly take heat from all buildings that have heat
			if buildings_to_cool_off != []:
				var cooling_per_building = spare_cooling_this_tick / buildings_to_cool_off.size()
				for heat_component in buildings_to_cool_off:
					heat_component.heat -= cooling_per_building
					Model.set_heat_to(
						heat_component.building_entity.player_id,
						heat_component.building_entity.position,
						heat_component.heat)

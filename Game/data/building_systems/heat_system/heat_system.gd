class_name HeatSystem
extends Node

# TODO: construct HeatFlowGraph per player
var heat_flow_graph: HeatFlowGraph

var residual_flow: HeatFlowGraph

func _ready() -> void:
	heat_flow_graph = HeatFlowGraph.new()
	ComponentManager.component_added.connect(_on_component_added)
	ComponentManager.component_removed.connect(_on_component_removed)

func _on_component_added(component: BuildingComponent) -> void:
	if component is HeatComponent:
		heat_flow_graph.add_building(component)
		calculate_residual_flow()
		print_flow_rates()

func _on_component_removed(component: BuildingComponent) -> void:
	if component is HeatComponent:
		heat_flow_graph.remove_building(component)
		calculate_residual_flow()
		print_flow_rates()

func calculate_residual_flow() -> void:
	residual_flow = heat_flow_graph.duplicate_graph()
	var augmenting_path = residual_flow.find_augmenting_path()
	while augmenting_path != []:
		residual_flow.augment_flow_along_path(augmenting_path)
		augmenting_path = residual_flow.find_augmenting_path()

func print_flow_rates() -> void:
	var heat_components = ComponentManager.get_components("HeatComponent")
	for heat_component: HeatComponent in heat_components:
		if heat_component.heat_building_type == Types.HeatBuilding.SOURCE:
			var heat_production = heat_component.heat_production
			var position = heat_component.building_entity.position
			var heat_consumed = residual_flow.graph.get_weight(position, HeatFlowGraph.SOURCE)
			print("heat component at %s: %d/%d" % [position, heat_consumed, heat_production])
		elif heat_component.heat_building_type == Types.HeatBuilding.SINK:
			var heat_passive_cool_off = heat_component.heat_passive_cool_off
			var position = heat_component.building_entity.position
			var heat_consumed = residual_flow.graph.get_weight(HeatFlowGraph.SINK, position)
			print("heat component at %s: %d/%d" % [position, heat_consumed, heat_passive_cool_off])

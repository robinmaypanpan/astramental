class_name HeatSystem
extends Node

# TODO: construct HeatFlowGraph per player
var heat_flow_graph: HeatFlowGraph

var residual_flow: Dictionary[Variant, Array]

func _ready() -> void:
	heat_flow_graph = HeatFlowGraph.new()
	ComponentManager.component_added.connect(_on_component_added)
	ComponentManager.component_removed.connect(_on_component_removed)

func _on_component_added(component: BuildingComponent) -> void:
	if component is HeatComponent:
		heat_flow_graph.add_building(component)

func _on_component_removed(component: BuildingComponent) -> void:
	if component is HeatComponent:
		heat_flow_graph.remove_building(component)

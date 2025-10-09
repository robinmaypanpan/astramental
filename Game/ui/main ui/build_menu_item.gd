class_name BuildMenuItem
extends Control
## A single entry in the build menu item table

## Scene to use to populate Cost list
@export var item_cost_scene: PackedScene

## The color to apply when this menu item is enabled
@export var enabled_modulation: Color

## The color to apply when this menu item is disabled
@export var disabled_modulation: Color

## Background color when hovered
@export var hovered_self_modulation: Color

## Background color when not hovered
@export var unhovered_self_modulation: Color

@onready var ready_light: ColorRect = %ReadyLight
@onready var icon: TextureRect = %Icon
@onready var building_name: Label = %Name
@onready var cost_container: Container = %Cost

# Sets the building resource this item shoudl represent
func set_building_resource(building: BuildingResource):
	icon.texture = building.icon
	building_name.text = building.name
	
	clear_cost_container()
	for item_cost: ItemCost in building.item_costs:
		var new_item_cost: BuildMenuItemCost = item_cost_scene.instantiate()
		cost_container.add_child(new_item_cost)
		new_item_cost.set_item_cost(item_cost)
		
		
func set_enabled(new_enabled: bool) -> void:
	if new_enabled:
		ready_light.color = Color.GREEN
		modulate = enabled_modulation
	else:
		ready_light.color = Color.RED
		modulate = disabled_modulation
		
		
func clear_cost_container() -> void:
	for child in cost_container.get_children():
		cost_container.remove_child(child)
		child.queue_free()


func _on_mouse_entered() -> void:
	self_modulate = hovered_self_modulation


func _on_mouse_exited() -> void:
	self_modulate = unhovered_self_modulation

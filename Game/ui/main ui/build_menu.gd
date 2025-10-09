class_name BuildMenu
extends MarginContainer

signal on_building_clicked(building_id: String)
signal available_buildings_changed()

@export var path_to_building_assets: String
@export var building_menu_item_scene: PackedScene

@onready var building_container: Container = %BuildingContainer


func _ready() -> void:
	# Clear list
	clear_building_list()

	for building: BuildingResource in Buildings.get_all_buildings():
		var new_menu_item: BuildMenuItem = building_menu_item_scene.instantiate()
		building_container.add_child(new_menu_item)
		new_menu_item.set_building_resource(building)
		
	Model.game_ready.connect(on_game_ready)

# PRIVATE METHODS

## Clears the list of buildings
func clear_building_list() -> void:
	for child in building_container.get_children():
		building_container.remove_child(child)
		child.queue_free()


func on_game_ready() -> void:
	# whether we can build a building is entirely dependent on our item counts
	var player_id: int = multiplayer.get_unique_id()
	var player_state: PlayerState = Model.player_states.get_state(player_id)
	player_state.item_count_changed.connect(_on_item_count_changed)


func _on_building_list_item_clicked(
	index: int, _at_position: Vector2, _mouse_button_index: int
) -> void:
	var building: BuildingResource = Buildings.get_all_buildings()[index]
	on_building_clicked.emit(building.id)


func _on_item_count_changed(_player_id: int, _type: Types.Item, _new_count: float) -> void:
	_disable_unaffordable_buildings()


## If a building is unaffordable with current resources, disable that building in UI
func _disable_unaffordable_buildings() -> void:
	var buildings = Buildings.get_all_buildings()
	for index in range(buildings.size()):
		var building_id: String = buildings[index].id
		var building_menu_item: BuildMenuItem = building_container.get_child(index)
		building_menu_item.set_enabled(Model.can_afford(building_id))
	available_buildings_changed.emit()

class_name PlayerState extends Node


## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float)

## When an item change rate changes, this signal fires
signal item_change_rate_changed(player_id: int, type: Types.Item, new_change_rate: float)

## When energy satisfaction changes, this signal fires
signal energy_satisfaction_changed(player_id: int, new_energy_satisfaction: float)

## The player id, assigned by the multiplayer controller.
@export var id: int

## The player index, which starts at 1 for the server and increases by 1 for each successive player.
@export var index: int

## The amount of each item that this player currently has.
@export var items: Dictionary[Types.Item, float]

## The change rate of each item that this player currently has.
@export var item_change_rate: Dictionary[Types.Item, float]

## The current energy satisfaction of all buildings, which defines how much of the current
## energy demand is satisfied by current energy production. Stored as a decimal between
## 0.0 and 1.0. Affects the speed at which buildings run.
@export var energy_satisfaction: float

## Contains the layout of the ores for each player.
## Stored as a 1D array that we index into with Model.get_ore_at and Model.set_ore_at.
@export var ores_layout: Array[Types.Ore]

## Contains a list of the positions of each building for this player.
@export var buildings_list: Array[BuildingEntity]

func _ready() -> void:
	# Initialize ores_layout array
	var num_layers := WorldGenModel.get_num_mine_layers()
	var layer_size := WorldGenModel.num_cols * WorldGenModel.layer_thickness
	ores_layout.resize(num_layers * layer_size)


## Expected to be used by the server to set the current rate and propogate the responses downstream
func update_item_change_rate(item: Types.Item, change_rate: float) -> void:
	assert(multiplayer.is_server())
	sync_item_change_rate.rpc(item, change_rate)


## Used by the server to set the item count
func update_item_count(type: Types.Item, amount: float) -> void:
	assert(multiplayer.is_server())
	sync_item_count.rpc(type, amount)

## Used by the server to set the energy satisfaction
func update_energy_satisfaction(new_es: float) -> void:
	assert(multiplayer.is_server())
	sync_energy_satisfaction.rpc(new_es)


## Set item count for both players and fire item_count_changed signal.
@rpc("any_peer", "call_local", "reliable")
func sync_item_count(type: Types.Item, amount: float) -> void:
	items[type] = amount
	item_count_changed.emit(id, type, amount)


## Set item change rate for both players and fire item_change_rate_changed signal.
@rpc("any_peer", "call_local", "reliable")
func sync_item_change_rate(type: Types.Item, change_rate: float) -> void:
	item_change_rate[type] = change_rate
	item_change_rate_changed.emit(id, type, change_rate)


## Set energy satisfaction for both players and fire energy_satisfaction_changed signal.
@rpc("any_peer", "call_local", "reliable")
func sync_energy_satisfaction(new_es: float) -> void:
	energy_satisfaction = new_es
	energy_satisfaction_changed.emit(id, new_es)


## Add a building to the buildings list.
## Also adds all corresponding components to ComponentManager.
func add_building(tile_position: Vector2i, building_id: String) -> void:
	buildings_list.append(
		BuildingEntity.new(id, tile_position, building_id)
	)


## Remove a building from the buildings list.
## Also removes all corresponding components from ComponentManager.
func remove_building(tile_position: Vector2i) -> bool:
	var index_to_remove := -1
	var building_entity: BuildingEntity = null
	for i in buildings_list.size():
		var placed_building : BuildingEntity = buildings_list[i]
		if placed_building.position == tile_position:
			index_to_remove = i
			building_entity = placed_building
			break
	if index_to_remove != -1:
		for component in building_entity.components:
			ComponentManager.remove_component(component)
		buildings_list.remove_at(index_to_remove)
		return true
	else:
		return false
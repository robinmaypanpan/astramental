class_name PlayerState extends Node

## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float)

## When an item production rate changes, this signal fires
signal item_production_changed(player_id: int, type: Types.Item, new_production: float)

## When an item consumption rate changes, this signal fires
signal item_consumption_changed(player_id: int, type: Types.Item, new_consumption: float)

## When energy satisfaction changes, this signal fires
signal energy_satisfaction_changed(player_id: int, new_energy_satisfaction: float)

## When storage cap changes, this signal fires
signal storage_cap_changed(player_id: int, type: Types.Item, new_cap: float)

## The player id, assigned by the multiplayer controller.
@export var id: int

## The player index, which starts at 1 for the server and increases by 1 for each successive player.
@export var index: int

## The current energy satisfaction of all buildings, which defines how much of the current
## energy demand is satisfied by current energy production. Stored as a decimal between
## 0.0 and 1.0. Affects the speed at which buildings run.
@export var energy_satisfaction: float

## Contains the layout of the ores for each player.
## Stored as a 1D array that we index into with Model.get_ore_at and Model.set_ore_at.
var ores_layout: Array[Types.Ore]

## Contains a list of the positions of each building for this player.
var buildings_list: Array[BuildingEntity]

## Contains a list of all cells where heat is located.
var heat_data_list: Array[HeatData]

## Model for all item information and accessing.
@onready var items: ItemModel = %ItemModel

## Model for all ore information.
@onready var ores: OreModel = %OreModel

func _ready() -> void:
	# Initialize ores_layout array
	var num_layers := WorldGenModel.get_num_mine_layers()
	var layer_size := WorldGenModel.num_cols * WorldGenModel.layer_thickness
	ores_layout.resize(num_layers * layer_size)


## Used by the server to set the energy satisfaction
func update_energy_satisfaction(new_energy_satisfaction: float) -> void:
	assert(multiplayer.is_server())
	if energy_satisfaction != new_energy_satisfaction:
		sync_energy_satisfaction.rpc(new_energy_satisfaction)


## Set energy satisfaction for both players and fire energy_satisfaction_changed signal.
@rpc("any_peer", "call_local", "reliable")
func sync_energy_satisfaction(new_energy_satisfaction: float) -> void:
	energy_satisfaction = new_energy_satisfaction
	energy_satisfaction_changed.emit(id, new_energy_satisfaction)


## Add a building to the buildings list.
## Also adds all corresponding components to ComponentManager.
func add_building(tile_position: Vector2i, building_id: String) -> void:
	var building: BuildingEntity = BuildingEntity.new(id, tile_position, building_id)
	ComponentManager.init_components_building(building)
	buildings_list.append(building)


## Remove a building from the buildings list.
## Also removes all corresponding components from ComponentManager.
func remove_building(tile_position: Vector2i) -> bool:
	var index_to_remove := -1
	var building_entity: BuildingEntity = null
	for i in buildings_list.size():
		var placed_building: BuildingEntity = buildings_list[i]
		if placed_building.position == tile_position:
			index_to_remove = i
			building_entity = placed_building
			break
	if index_to_remove != -1:
		ComponentManager.remove_components_building(building_entity)
		buildings_list.remove_at(index_to_remove)
		return true
	else:
		return false


# TODO: remove this by rewriting how UI updates
## Temporary code to fire all changed signals based on the new item model counts.
func fire_all_changed_signals() -> void:
	for item in Types.Item.values():
		item_count_changed.emit(id, item, items.counts.get_for(item))
		item_consumption_changed.emit(id, item, items.consumption.get_for(item))
		item_production_changed.emit(id, item, items.production.get_for(item))
		storage_cap_changed.emit(id, item, items.storage_caps.get_for(item))


## Sync all properties of this state to the network.
func sync() -> void:
	items.sync()
	ores.sync()


func _on_multiplayer_synchronizer_synchronized() -> void:
	# This acts kinda weird. Hooking off synchronize calls this like 8 times a tick, and hooking
	# off delta_synchronize makes it call like 1-2 times a tick.
	print("received synchronize as %d" % [multiplayer.get_unique_id()])
	fire_all_changed_signals()

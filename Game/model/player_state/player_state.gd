class_name PlayerState extends Node

## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float)

## When an item production rate changes, this signal fires
signal item_production_changed(player_id: int, type: Types.Item, new_production: float)

## When an item consumption rate changes, this signal fires
signal item_consumption_changed(player_id: int, type: Types.Item, new_consumption: float)

## When storage cap changes, this signal fires
signal storage_cap_changed(player_id: int, type: Types.Item, new_cap: float)

## The player id, assigned by the multiplayer controller.
@export var id: int

## The player index, which starts at 1 for the server and increases by 1 for each successive player.
@export var index: int

## The current energy satisfaction of all buildings, which defines how much of the current
## energy demand is satisfied by current energy production. Stored as a decimal between
## 0.0 and 1.0. Affects the speed at which buildings run.
@export var energy_satisfaction: float:
	get:
		# TODO: fix so we don't constantly have to check for null.
		# Currently game crashes if you don't do this.
		var value: Variant = _energy_satisfaction.value_client
		if value != null:
			return value
		else:
			return 0.0
	set(new_value):
		_energy_satisfaction.value_client = new_value

## Model for all item information and accessing.
@onready var items: ItemModel = %ItemModel

## Model for all ore information.
@onready var ores: OreModel = %OreModel

## Model for all building information.
@onready var buildings: BuildingModel = %BuildingModel

## Model for all building heat information.
@onready var building_heat: BuildingHeatModel = %BuildingHeatModel

## The Building entity-component system.
@onready var building_ecs: BuildingEcs = %BuildingEcs

## Internal energy satisfaction property.
@onready var _energy_satisfaction: SyncProperty = %EnergySatisfaction


func _ready() -> void:
	energy_satisfaction = 0.0


## Add a building to the buildings list.
## Also adds all corresponding components to ComponentManager.
func add_building(tile_position: Vector2i, building_id: String) -> void:
	assert(multiplayer.is_server())
	var building = buildings.add_building(tile_position, building_id)
	building_ecs.component_manager.add_components_building(building)


## Remove a building from the buildings list.
## Also removes all corresponding components from ComponentManager.
func remove_building(tile_position: Vector2i) -> bool:
	assert(multiplayer.is_server())
	var building_at_pos = buildings.get_building_at_pos(tile_position)
	if building_at_pos:
		buildings.remove_building(building_at_pos.unique_id)
		building_ecs.component_manager.remove_components_building(building_at_pos)
		return true
	else:
		return false


# TODO: remove this by rewriting how UI updates
## Temporary code to fire all changed signals based on the new item model counts.
func fire_all_changed_signals() -> void:
	Model.heat_data_updated.emit()


## Update all systems for the building ECS. Only callable by server.
func update_systems() -> void:
	assert(multiplayer.is_server())
	if building_ecs != null:
		building_ecs.update()


## Publish all properties of this state to the network.
func publish() -> void:
	items.publish()
	ores.publish()
	buildings.publish()
	building_heat.publish()
	_energy_satisfaction.publish()


## Sync all properties of this state from the network.
func sync() -> void:
	ores.sync()
	items.sync()
	buildings.sync()
	building_heat.sync()
	_energy_satisfaction.sync()


func _on_multiplayer_synchronizer_synchronized() -> void:
	# This acts kinda weird. Hooking off synchronize calls this like 8 times a tick, and hooking
	# off delta_synchronize makes it call like 1-2 times a tick.
	print("received synchronize as %d" % [multiplayer.get_unique_id()])
	# TODO: implement a method to diff between received network data and current data in
	# deserialization
	sync()
	fire_all_changed_signals()

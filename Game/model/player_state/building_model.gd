class_name BuildingModel
extends Node
## Model for buildings. Getters read from real copy i.e. last frame's data, and setters set to the
## shadow copy. Values are synced between players by calling sync(), which copies from shadow to
## real copy and serializes it across the network, which clients then deserialize.

## Array of buildings turned into primitives that is synchronized with MultiplayerSynchronizer.
@export var buildings_serialized: Array[Dictionary]

## Array of buildings, stored internally.
var buildings: Array[BuildingEntity]

## Shadow copy of buildings.
var _buildings_shadow: Array[BuildingEntity] = []

## Next number to use for the id of new buildings.
var _next_building_unique_id: int = 0

# TODO: remove this
## The player_id these buildings are associated with
@onready var _player_id = get_parent().id


## Return the building at the given position, if it exists.
func get_building_at_pos(grid_position: Vector2i) -> BuildingEntity:
	var index: int = buildings.find_custom(
		func(elem): return elem.position == grid_position
	)
	if index != -1:
		return buildings[index]
	else:
		return null


## Return the building with the given unique id, if it exists.
func get_building(unique_id: int) -> BuildingEntity:
	var index: int = buildings.find_custom(
		func(elem): return elem.unique_id == unique_id
	)
	if index != -1:
		return buildings[index]
	else:
		return null


## Return a list of all buildings.
func get_all() -> Array[BuildingEntity]:
	return buildings


## Add a building to the model.
func add_building(grid_position: Vector2i, building_id: String) -> BuildingEntity:
	var building: BuildingEntity = BuildingEntity.new(
		_next_building_unique_id,
		_player_id,
		grid_position,
		building_id
	)
	_next_building_unique_id += 1
	_buildings_shadow.append(building)
	return building


## Remove a building from the model.
func remove_building(unique_id: int) -> void:
	var index_to_remove = _buildings_shadow.find_custom(
		func(elem): return elem.unique_id == unique_id
	)
	if index_to_remove != -1:
		_buildings_shadow.remove_at(index_to_remove)


## Synchronize buildings across network by updating actual buildings, then serializing them to
## synchronize across network.
func sync() -> void:
	buildings = _buildings_shadow.duplicate()
	serialize_buildings()


## Set `buildings_serialized` by serializing `buildings`.
func serialize_buildings() -> void:
	var new_buildings_serialized: Array[Dictionary] = []
	for building: BuildingEntity in buildings:
		new_buildings_serialized.append(building.serialize())
	buildings_serialized = new_buildings_serialized


## Set `buildings` by deserializing received `buildings_serialized` data.
func deserialize_buildings() -> void:
	var new_buildings: Array[BuildingEntity] = []
	for building_serialized: Dictionary in buildings_serialized:
		new_buildings.append(BuildingEntity.from_serialized(building_serialized))
	buildings = new_buildings
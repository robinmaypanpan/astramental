class_name BuildingEntity
extends Object
## Represents a building actually placed down in the Model.

## Unique unique_id used to identify this building.
var unique_id: int

# TODO: Remove this
## Which player placed this building.
var player_id: int

## The tile position of the building.
var position: Vector2i

## What building is here.
var building_id: String

## List of components keeping track of behavior.
var components: Array[BuildingComponent]


func _init(in_unique_id: int, in_player_id: int, in_position: Vector2i, in_building_id: String):
	unique_id = in_unique_id
	player_id = in_player_id
	position = in_position
	building_id = in_building_id
	# components will be initialized by player state


## Returns the building resource associated with this building
func get_resource() -> BuildingResource:
	return Buildings.get_by_id(building_id)


## Returns the component of the given type, or null if not found.
func get_component(component_type: String) -> BuildingComponent:
	for component in components:
		if component.type == component_type:
			return component
	return null


## Return a primitive object that can be synchronized across the network with
## MultiplayerSynchronizer.
func serialize() -> Dictionary:
	var serialized_building_entity: Dictionary = {}
	serialized_building_entity["unique_id"] = unique_id
	serialized_building_entity["player_id"] = player_id
	serialized_building_entity["position"] = position
	serialized_building_entity["building_id"] = building_id

	return serialized_building_entity


## Given a primitive object of this type received over the network, turn it into a BuildingEntity.
static func from_serialized(serialized_building_entity: Dictionary) -> BuildingEntity:
	var new_unique_id: int = serialized_building_entity["unique_id"]
	var new_player_id: int = serialized_building_entity["player_id"]
	var new_position: Vector2i = serialized_building_entity["position"]
	var new_building_id: String = serialized_building_entity["building_id"]
	var new_building_entity: BuildingEntity = (
		BuildingEntity.new(
			new_unique_id,
			new_player_id,
			new_position,
			new_building_id,
		)
	)

	return new_building_entity

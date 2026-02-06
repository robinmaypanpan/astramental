class_name BuildingEntity
extends Object
## Represents a building actually placed down in the Model.

## Unique ID used to identify this building.
var unique_id: int

# TODO: Remove this
## Which player placed this building.
var player_id: int

## The tile position of the building.
var position: Vector2i

## What building is here.
var building_id: String


func _init(in_unique_id: int, in_player_id: int, in_position: Vector2i, in_building_id: String):
	unique_id = in_unique_id
	player_id = in_player_id
	position = in_position
	building_id = in_building_id
	# components will be initialized by player state


## Returns the building resource associated with this building
func get_resource() -> BuildingResource:
	return Buildings.get_by_id(building_id)


# TODO: rewrite serialization to return PackedByteArray instead of Dictionary
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


static func not_equal(building_entity_1: BuildingEntity, building_entity_2: BuildingEntity) -> bool:
	return (
		building_entity_1.unique_id != building_entity_2.unique_id
		or building_entity_1.player_id != building_entity_2.player_id
		or building_entity_1.position != building_entity_2.position
		or building_entity_1.building_id != building_entity_2.building_id
	)
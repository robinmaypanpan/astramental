class_name BuildingModel
extends SyncProperty
## Model for buildings.

## Next number to use for the id of new buildings.
var _next_building_unique_id: int = 0

# TODO: remove this at the same time we remove player id from BuildingEntity
## The player_id these buildings are associated with
@onready var _player_id = get_parent().id


func _ready() -> void:
	value_client = [] as Array[BuildingEntity]


## Return the building at the given position, if it exists.
func get_building_at_pos(grid_position: Vector2i) -> BuildingEntity:
	var index: int = value_client.find_custom(func(elem): return elem.position == grid_position)
	if index != -1:
		return value_client[index]
	else:
		return null


## Return the building with the given unique id, if it exists.
func get_building(unique_id: int) -> BuildingEntity:
	var index: int = value_client.find_custom(func(elem): return elem.unique_id == unique_id)
	if index != -1:
		return value_client[index]
	else:
		return null


## Return a list of all buildings.
func get_all() -> Array[BuildingEntity]:
	return value_client


## Add a building to the model.
func add_building(grid_position: Vector2i, building_id: String) -> BuildingEntity:
	print_debug("adding building id %d" % _next_building_unique_id)
	var building: BuildingEntity = BuildingEntity.new(
		_next_building_unique_id, _player_id, grid_position, building_id
	)
	_next_building_unique_id += 1
	value_client.append(building)
	return building


## Remove a building from the model.
func remove_building(unique_id: int) -> void:
	print_debug("removing building id %d" % unique_id)
	var index_to_remove = value_client.find_custom(func(elem): return elem.unique_id == unique_id)
	if index_to_remove != -1:
		value_client.remove_at(index_to_remove)


func serialize(value: Variant) -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	for building: BuildingEntity in value:
		# encode each building as:
		# [0]: size of encoded building: 1 byte (this implies encoded buildings are <= 255 bytes in size)
		# [1]: encoded building: X bytes
		var building_dict: Dictionary = building.serialize()
		var building_bytes: PackedByteArray = var_to_bytes(building_dict)
		var building_bytes_size: int = building_bytes.size()
		bytes.append(building_bytes_size)
		bytes.append_array(building_bytes)
	return bytes


func deserialize(bytes: PackedByteArray) -> Variant:
	var new_value: Array[BuildingEntity] = []
	var curr_offset: int = 0
	var bytes_size: int = bytes.size()
	while curr_offset < bytes_size:
		var building_bytes_size = bytes.decode_u8(curr_offset)
		curr_offset += 1
		var building_dict = bytes_to_var(
			bytes.slice(curr_offset, curr_offset + building_bytes_size)
		)
		curr_offset += building_bytes_size
		var building_entity = BuildingEntity.from_serialized(building_dict)
		new_value.append(building_entity)
	return new_value


func not_equal(value1: Variant, value2: Variant) -> bool:
	if value1.size() != value2.size():
		return true

	for i in range(value1.size()):
		var building_entity_1 = value1[i]
		var building_entity_2 = value2[i]
		if BuildingEntity.not_equal(building_entity_1, building_entity_2):
			return true

	return false

class_name BuildingHeatModel
extends SyncProperty
## All information about building heat data.


func _ready() -> void:
	value_client = [] as Array[HeatData]


## Add the given heat data to the heat model.
func add(heat_data: HeatData) -> void:
	value_client.append(heat_data)


## Remove the heat data for the object at the given grid position.
func remove_at_pos(grid_position: Vector2i) -> void:
	var index_to_remove: int = _get_index_by_pos(grid_position)
	if index_to_remove != -1:
		value_client.remove_at(index_to_remove)


## Find the heat data for the object at the given grid position.
func get_at_pos(grid_position: Vector2i) -> HeatData:
	var index: int = _get_index_by_pos(grid_position)
	if index == -1:
		return null
	return value_client[index]


## Get all heat data for every object.
func get_all() -> Array[HeatData]:
	return value_client


## Set the heat value of the object at the given position to the new heat value.
func set_heat(grid_position: Vector2i, new_heat: float) -> void:
	var index: int = _get_index_by_pos(grid_position)
	if index == -1:
		assert(
			false,
			"Attempting to set heat value for nonexistent object at position %s" % [grid_position]
		)
	var heat_data: HeatData = value_client[index]
	heat_data.heat = new_heat


## Set the heat state of the object at the given position to the new heat state.
func set_heat_state(grid_position: Vector2i, new_heat_state: Types.HeatState) -> void:
	var index: int = _get_index_by_pos(grid_position)
	if index == -1:
		assert(
			false,
			"Attempting to set heat state for nonexistent object at position %s" % [grid_position]
		)
	var heat_data: HeatData = value_client[index]
	heat_data.heat_state = new_heat_state


func serialize(value: Variant) -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(11 * value.size())

	var curr_offset: int = 0
	for heat_data: HeatData in value:
		_encode_heat_data(bytes, curr_offset, heat_data)
		curr_offset += 11

	return bytes


func deserialize(bytes: PackedByteArray) -> Variant:
	var heat_data_array: Variant = [] as Array[HeatData]

	var curr_offset: int = 0
	var bytes_size: int = bytes.size()
	while curr_offset < bytes_size:
		heat_data_array.append(_decode_heat_data(bytes, curr_offset))
		curr_offset += 11

	return heat_data_array


## Take a HeatData object and encode it into the PackedByteArray at the given offset.
func _encode_heat_data(bytes: PackedByteArray, offset: int, heat_data: HeatData) -> void:
	# layout: (11 bytes)
	# - position.x: 1 byte
	# - position.y: 1 byte
	# - heat: 4 bytes
	# - heat_capacity: 4 bytes
	# - heat_state: 1 byte
	bytes.encode_u8(offset, heat_data.position.x)
	bytes.encode_u8(offset + 1, heat_data.position.y)
	bytes.encode_float(offset + 2, heat_data.heat)
	bytes.encode_float(offset + 6, heat_data.heat_capacity)
	bytes.encode_u8(offset + 10, heat_data.heat_state)


## Decode the HeatData object at the given offset in the PackedByteArray.
func _decode_heat_data(bytes: PackedByteArray, offset: int) -> HeatData:
	var position_x: int = bytes.decode_u8(offset)
	var position_y: int = bytes.decode_u8(offset + 1)
	var heat: float = bytes.decode_float(offset + 2)
	var heat_capacity: float = bytes.decode_float(offset + 6)
	var heat_state: Types.HeatState = bytes.decode_u8(offset + 10) as Types.HeatState
	var position: Vector2i = Vector2i(position_x, position_y)
	return HeatData.new(position, heat, heat_capacity, heat_state)


## Given the grid position, find the index in the heat data array of the heat data with the given
## position.
func _get_index_by_pos(grid_position: Vector2i) -> int:
	return value_client.find_custom(func(elem): return elem.position == grid_position)

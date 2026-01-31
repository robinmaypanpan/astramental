class_name OreModel
extends SyncProperty
## Model for Ores.

## Cached layer thickness: number of rows in each layer.
var _layer_thickness: int

## Cached layer width: number of columns in each layer.
var _layer_width: int


func _ready() -> void:
	var world_gen_model: WorldGenModel = Model.world_gen_model
	_layer_thickness = world_gen_model.num_rows_layer
	_layer_width = world_gen_model.num_cols

	var num_layers: int = world_gen_model.num_mine_layers
	var layer_size: int = _layer_thickness * _layer_width
	var ores_size: int = num_layers * layer_size
	# resize ores to appropriate size
	value_client = [] as Array[Types.Ore]
	value_client.resize(ores_size)
	value_client.fill(Types.Ore.ROCK)


## Get the ore at the given position.
func get_ore(grid_position: Vector2i) -> Types.Ore:
	var index = _get_index_into_ores(grid_position)
	return value_client[index]


## Set the ore at the given position to the given value.
func set_ore(grid_position: Vector2i, new_ore: Types.Ore) -> void:
	# TODO: do all ore generation server side, and not client side
	# assert(multiplayer.is_server())
	var index = _get_index_into_ores(grid_position)
	value_client[index] = new_ore


func serialize(value: Variant) -> PackedByteArray:
	var bytes = PackedByteArray()
	var ores_size: int = value.size()
	bytes.resize(ores_size)
	for i in range(ores_size):
		bytes.encode_u8(i, value[i])
	return bytes


func deserialize(bytes: PackedByteArray) -> Variant:
	var new_value: Variant = [] as Array[Types.Ore]
	var ores_size: int = bytes.size()
	new_value.resize(ores_size)
	for i in range(ores_size):
		new_value[i] = bytes.decode_u8(i) as Types.Ore
	return new_value


## Given the 2D grid position of the ore, get the actual index into the 1D array.
func _get_index_into_ores(grid_position: Vector2i) -> int:
	# TODO: rewrite this so no subtraction is required.
	if Model.world_gen_model.get_layer_num(grid_position.y) > 0:
		grid_position.y -= _layer_thickness
		return grid_position.y * _layer_width + grid_position.x
	else:
		assert(false, "Attempting to index into ores with invalid grid position %s" % grid_position)
		return -1

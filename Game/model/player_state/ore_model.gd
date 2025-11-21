class_name OreModel
extends Node
## Model for Ores. Getters read from real copy i.e. last frame's data, and setters set to the
## shadow copy. Values are synced between players by calling sync(), which copies from shadow to
## real copy.

## Array of ores, stored as a 1D array.
@export var ores: Array[Types.Ore]

## Shadow copy of ores, stored as a 1D array.
var _ores_shadow: Array[Types.Ore]

## Cached layer thickness: number of rows in each layer.
var _layer_thickness: int

## Cached layer width: number of columns in each layer.
var _layer_width: int


func _ready() -> void:
	_layer_thickness = WorldGenModel.layer_thickness
	_layer_width = WorldGenModel.num_cols

	var num_layers: int = WorldGenModel.get_num_mine_layers()
	var layer_size: int = _layer_thickness * _layer_width
	var ores_size: int = num_layers * layer_size
	# resize ores to appropriate size
	ores.resize(ores_size)
	_ores_shadow.resize(ores_size)


## Get the ore at the given position.
func get_ore(grid_position: Vector2i) -> Types.Ore:
	var index = _get_index_into_ores(grid_position)
	return ores[index]


## Get the ore at the given position from the shadow array.
func get_ore_shadow(grid_position: Vector2i) -> Types.Ore:
	assert(multiplayer.is_server())
	var index = _get_index_into_ores(grid_position)
	return _ores_shadow[index]


## Set the ore at the given position to the given value.
func set_ore(grid_position: Vector2i, new_ore: Types.Ore) -> void:
	# TODO: do all ore generation server side, and not client side
	# assert(multiplayer.is_server())
	var index = _get_index_into_ores(grid_position)
	_ores_shadow[index] = new_ore


## Sync all properties of this model across the network.
func sync() -> void:
	ores = _ores_shadow.duplicate()


## Given the 2D grid position of the ore, get the actual index into the 1D array.
func _get_index_into_ores(grid_position: Vector2i) -> int:
	# TODO: rewrite this so no subtraction is required.
	if WorldGenModel.get_layer_num(grid_position.y) > 0:
		grid_position.y -= _layer_thickness
		return grid_position.y * _layer_width + grid_position.x
	else:
		assert(false, "Attempting to index into ores with invalid grid position %s" % grid_position)
		return -1

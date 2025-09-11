extends Node

# game board properties
@export var num_cols: int = 10
@export var layer_thickness: int = 7
@export var sky_height: int = 300
@export var tile_map_scale: int = 2
## Resource generation information stored as an array. Index 0 corresponds to 1st mine layer, index 1 is 2nd mine layer, and so on.
@export var ores_generation: Array[LayerGenerationResource]

## Given the layer number, return the resource generation information for that layer. Layer 0 is the factory/topmost layer, layer 1 is the 1st mine layer, and so on.
func get_layer_generation_data(layer_num: int) -> LayerGenerationResource:
	if layer_num > 0:
		return ores_generation[layer_num - 1]
	else:
		return null

## Return the number of layers that are being generated for the mines.
func get_num_mine_layers() -> int:
	return ores_generation.size()

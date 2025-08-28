extends Node

@export var ores_tileset: TileSet
## Stores mapping from ore type -> ore resource data
@export var ores_dict: Dictionary[Ore.Type, OreResource]
## Resource generation information stored as an array. Index 0 corresponds to layer 0/top most layer generation, index 1 corresponse to layer 1, and so forth.
@export var ores_generation: Array[LayerGenerationResource]

## Given ore type, return the coordinates in the tile set that correspond to that ore image.
func get_atlas_coordinates(type: Ore.Type) -> Vector2i:
	return ores_dict[type].atlas_coordinates

## Given ore type, return the item that that ore should yield when mined.
func get_yield(type: Ore.Type) -> Item.Type:
	return ores_dict[type].item_yield

## Given the layer number, return the resource generation information for that layer. Layer 0 is the topmost layer, layer 1 is the layer below that, and so on.
func get_layer_generation_data(layer_num: int) -> LayerGenerationResource:
	return ores_generation[layer_num]

## Return the number of layers that are being generated for the mines.
func get_num_mine_layers() -> int:
	return ores_generation.size()

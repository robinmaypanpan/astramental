extends Node

@export var ores_tileset: TileSet
@export var ores_dict: Dictionary[Ore.Type, OreResource]
@export var ores_generation: Array[LayerGenerationResource]

func get_atlas_coordinates(type: Ore.Type) -> Vector2i:
	return ores_dict[type].atlas_coordinates

func get_yield(type: Ore.Type) -> Item.Type:
	return ores_dict[type].item_yield

func get_layer_generation_data(layer_num: int) -> LayerGenerationResource:
	return ores_generation[layer_num]

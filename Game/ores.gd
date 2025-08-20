extends Node

@export var ores_tileset: TileSet
@export var ores_dict: Dictionary[Ore.Type, OreResource]

func get_info(type: Ore.Type) -> OreResource:
	return ores_dict[type]

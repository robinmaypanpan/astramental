extends Node

@export var ores_tileset: TileSet
## Stores mapping from ore type -> ore resource data
@export var ores_dict: Dictionary[Types.Ore, OreResource]

## Returns the ore resource for the given type
func get_ore_resource(type: Types.Ore) -> OreResource:
	return ores_dict[type]


## Given ore type, return the coordinates in the tile set that correspond to that ore image.
func get_atlas_coordinates(type: Types.Ore) -> Vector2i:
	return ores_dict[type].atlas_coordinates


## Given ore type, return the item that that ore should yield when mined.
func get_yield(type: Types.Ore) -> Types.Item:
	return ores_dict[type].item_yield

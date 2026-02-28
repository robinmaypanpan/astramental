extends Node

## Stores mapping from ore type -> ore resource data
@export var ores_dict: Dictionary[Types.Ore, OreResource]


## Returns the ore resource for the given type
func get_ore_resource(type: Types.Ore) -> OreResource:
	return ores_dict[type]


## Given ore type, return the item that that ore should yield when mined.
func get_yield(type: Types.Ore) -> Types.Item:
	return ores_dict[type].item_yield

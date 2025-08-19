extends Node

@export var items_dict: Dictionary[Item.Type, ItemResource]

func get_info(type: Item.Type) -> ItemResource:
	return items_dict[type]

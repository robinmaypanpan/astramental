extends Node

## Stores mapping from item type -> item resource data
@export var items_dict: Dictionary[Item.Type, ItemResource]

## Given an item type, return the item information for that item.
func get_info(type: Item.Type) -> ItemResource:
	return items_dict[type]

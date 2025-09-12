extends Node

## Stores mapping from item type -> item resource data
@export var items_dict: Dictionary[Types.Item, ItemResource]


## Given an item type, return the item information for that item.
func get_info(type: Types.Item) -> ItemResource:
	return items_dict[type]

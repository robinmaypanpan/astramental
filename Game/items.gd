extends Node

@export var items_list: Array[ItemResource]

var items_dict: Dictionary

func get_info(type: Item.Type) -> ItemResource:
	return items_dict[type]

func _ready() -> void:
	for type in Item.Type.values():
		for item in items_list:
			if type == item.type:
				items_dict[type] = item
				break # break inner loop, outer loop keeps going

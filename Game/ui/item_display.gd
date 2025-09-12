extends MarginContainer

## An instance of a single display row for a single item.
@export var item_display_row: PackedScene

@onready var _item_display_list := %ItemDisplayList
@onready var _Model := %Model

## Mapping from item type -> instantiated item display row.
var _item_type_to_row_dict: Dictionary[Types.Item, Node]

func _ready() -> void:
	# set up an item display row for every item type
	for type in Types.Item.values():
		var new_row := item_display_row.instantiate()
		new_row.item_type = type
		_item_display_list.add_child(new_row)
		# add new item display row to the dictionary
		_item_type_to_row_dict[type] = new_row

## Update the counts of all items to their current resource amounts. Must be called manually for the resource numbers to update.
func update_counts() -> void:
	var player_id: int = multiplayer.get_unique_id()
	for type in Types.Item.values():
		var my_item_count: int = _Model.get_item_count(player_id, type)
		_item_type_to_row_dict[type].update_count(my_item_count)

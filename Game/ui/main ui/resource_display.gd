class_name ResourceDisplay extends Control

## An instance of a single display row for a single item.
@export var item_display_row: PackedScene

## Mapping from item type -> instantiated item display row.
var _item_type_to_row_dict: Dictionary[Types.Item, Node]

@onready var _item_display_list := %ItemDisplayList


func _ready() -> void:
	# set up an item display row for every item type
	for type in Types.Item.values():
		var new_row := item_display_row.instantiate()
		new_row.item_type = type
		_item_display_list.add_child(new_row)
		# add new item display row to the dictionary
		_item_type_to_row_dict[type] = new_row

	Model.item_count_changed.connect(_update_item_count)
	Model.game_ready.connect(_update_item_count)
	

## Updates the nubmer of items located currently
func _update_item_count(_player_id: int, type: Types.Item, new_count: float) -> void:
	_item_type_to_row_dict[type].update_count(new_count)


## Update the counts of all items to their current resource amounts.
## Must be called manually for the resource numbers to update.
func _update_all_item_counts() -> void:
	for type in Types.Item.values():
		var player_id: int = multiplayer.get_unique_id()
		var item_count: int = Model.get_item_count(player_id, type)

		_item_type_to_row_dict[type].update_count(item_count)

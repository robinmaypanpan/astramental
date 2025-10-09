class_name ResourceDisplay extends Control

## An instance of a single display row for a single item.
@export var item_display_row: PackedScene

## Mapping from item type -> instantiated item display row.
var _item_type_to_row_dict: Dictionary[Types.Item, Node]

@onready var _item_display_list := %ItemDisplayList


func _ready() -> void:
	clear_item_display_list()
	# set up an item display row for every item type
	for type in Types.Item.values():
		var new_row := item_display_row.instantiate()
		new_row.item_type = type
		_item_display_list.add_child(new_row)
		# add new item display row to the dictionary
		_item_type_to_row_dict[type] = new_row
		
	Model.game_ready.connect(on_game_ready)

# PRIVATE METHODS

func clear_item_display_list():
	for child in _item_display_list.get_children():
		_item_display_list.remove_child(child)
		child.queue_free()

## Updates the nubmer of items located currently
func _update_item_count(_player_id: int, type: Types.Item, new_count: float) -> void:
	_item_type_to_row_dict[type].update_count(new_count)


## Updates the change rate of items located currently
func _update_item_change_rate(_player_id: int, type: Types.Item, new_change_rate: float) -> void:
	_item_type_to_row_dict[type].update_change_rate(new_change_rate)


func on_game_ready() -> void:
	# Connect to the local changes in item count and change rate
	var player_id: int = multiplayer.get_unique_id()
	var player_state: PlayerState = Model.player_states.get_state(player_id)
	player_state.item_count_changed.connect(_update_item_count)
	player_state.item_change_rate_changed.connect(_update_item_change_rate)

	resync_item_counts()


## Update the counts of all items to their current resource amounts.
## Must be called manually for the resource numbers to update.
func resync_item_counts() -> void:
	for type in Types.Item.values():
		var player_id: int = multiplayer.get_unique_id()
		var item_row = _item_type_to_row_dict[type]

		item_row.update_count(Model.get_item_count(player_id, type))
		item_row.update_change_rate(Model.get_item_change_rate(player_id, type))

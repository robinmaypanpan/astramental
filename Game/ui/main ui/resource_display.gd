class_name ResourceDisplay extends Control

## An instance of a single display row for a single item.
@export var item_display_row: PackedScene

## Mapping from item type -> instantiated item display row.
var item_type_to_row_dict: Dictionary[Types.Item, ItemDisplayRow]

@onready var _item_display_list := %ItemDisplayList


func _ready() -> void:
	clear_item_display_list()
	Model.game_ready.connect(on_game_ready)

# PRIVATE METHODS

func clear_item_display_list():
	for child in _item_display_list.get_children():
		_item_display_list.remove_child(child)
		child.queue_free()

## Updates the nubmer of items located currently
func _update_item_count(_player_id: int, type: Types.Item, new_count: float) -> void:
	if new_count > 0 or item_type_to_row_dict.has(type):
		get_or_create_item_row(type).update_count(new_count)


## Updates the change rate of items located currently
func _update_item_change_rate(_player_id: int, type: Types.Item, new_change_rate: float) -> void:
	if new_change_rate > 0 or item_type_to_row_dict.has(type):
		get_or_create_item_row(type).update_change_rate(new_change_rate)


## Updates item storage bar based on new storage cap
func _update_storage_cap(_player_id: int, type: Types.Item, new_cap: float) -> void:
	# Do not add row if it isn't already there
	if item_type_to_row_dict.has(type):
		item_type_to_row_dict[type].update_storage_cap(new_cap)


func on_game_ready() -> void:
	# Connect to the local changes in item count and change rate
	var player_id: int = multiplayer.get_unique_id()
	var player_state: PlayerState = Model.player_states.get_state(player_id)
	player_state.item_count_changed.connect(_update_item_count)
	player_state.item_change_rate_changed.connect(_update_item_change_rate)
	player_state.storage_cap_changed.connect(_update_storage_cap)

	resync_item_counts()

func get_or_create_item_row(item_type: Types.Item) -> ItemDisplayRow:
	if item_type_to_row_dict.has(item_type):
		return item_type_to_row_dict[item_type]
	else:
		var new_row := item_display_row.instantiate()
		new_row.item_type = item_type
		_item_display_list.add_child(new_row)
		# add new item display row to the dictionary
		item_type_to_row_dict[item_type] = new_row
		return new_row


## Update the counts of all items to their current resource amounts.
## Must be called manually for the resource numbers to update.
func resync_item_counts() -> void:
	var player_id: int = multiplayer.get_unique_id()

	for type in Types.Item.values():
		var item_count: float = Model.get_item_count(player_id, type)
		var item_change_rate: float = Model.get_item_change_rate(player_id, type)

		if item_count > 0 or item_change_rate > 0 or item_type_to_row_dict.has(type):
			# Check if we're over 0 or if we've ever been over 0
			var item_row: ItemDisplayRow = get_or_create_item_row(type)

			item_row.update_count(item_count)
			item_row.update_change_rate(item_change_rate)

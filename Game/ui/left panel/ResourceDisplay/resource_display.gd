class_name ResourceDisplay extends Control

## An instance of a single display row for a single item.
@export var item_display_row: PackedScene

## Mapping from item type -> instantiated item display row.
var item_type_to_row_dict: Dictionary[Types.Item, ItemDisplayRow]

var player_items: ItemModel

@onready var _item_display_list := %ItemDisplayList


func _ready() -> void:
	clear_item_display_list()
	Model.game_ready.connect(on_game_ready)


# PRIVATE METHODS


func clear_item_display_list():
	for child in _item_display_list.get_children():
		_item_display_list.remove_child(child)
		child.queue_free()


## Updates the number of items located currently
func _update_item_counts() -> void:
	for item in Types.Item.values():
		var new_count: float = player_items.counts.get_for(item)
		if new_count > 0 or item_type_to_row_dict.has(item):
			get_or_create_item_row(item).update_count(new_count)


## Updates the change rate of items located currently
func _update_item_productions() -> void:
	for item in Types.Item.values():
		var new_production_rate: float = player_items.production.get_for(item)
		if new_production_rate > 0 or item_type_to_row_dict.has(item):
			var new_change_rate: float = player_items.get_item_change_rate(item)
			get_or_create_item_row(item).update_change_rate(new_change_rate)


## Updates the change rate of items located currently
func _update_item_consumptions() -> void:
	for item in Types.Item.values():
		var new_consumption_rate: float = player_items.consumption.get_for(item)
		if new_consumption_rate > 0 or item_type_to_row_dict.has(item):
			var new_change_rate: float = player_items.get_item_change_rate(item)
			get_or_create_item_row(item).update_change_rate(new_change_rate)


## Updates item storage bar based on new storage cap
func _update_storage_caps() -> void:
	for item in Types.Item.values():
		var new_cap = player_items.storage_caps.get_for(item)
		if item_type_to_row_dict.has(item):
			item_type_to_row_dict[item].update_storage_cap(new_cap)


func on_game_ready() -> void:
	# Connect to the local changes in item count and change rate
	var player_id: int = multiplayer.get_unique_id()
	var player_state: PlayerState = Model.player_states.get_state(player_id)
	player_items = player_state.items
	player_items.counts.changed.connect(_update_item_counts)
	player_items.production.changed.connect(_update_item_productions)
	player_items.consumption.changed.connect(_update_item_consumptions)
	player_items.storage_caps.changed.connect(_update_storage_caps)

	resync_item_counts()


func get_or_create_item_row(item: Types.Item) -> ItemDisplayRow:
	if item_type_to_row_dict.has(item):
		return item_type_to_row_dict[item]
	else:
		var new_row := item_display_row.instantiate()
		new_row.item_type = item
		_item_display_list.add_child(new_row)
		# add new item display row to the dictionary
		item_type_to_row_dict[item] = new_row
		return new_row


## Update the counts of all items to their current resource amounts.
## Must be called manually for the resource numbers to update.
func resync_item_counts() -> void:
	for item in Types.Item.values():
		var item_count: float = player_items.counts.get_for(item)
		var item_change_rate: float = player_items.get_item_change_rate(item)

		if item_count > 0 or item_change_rate > 0 or item_type_to_row_dict.has(item):
			# Check if we're over 0 or if we've ever been over 0
			var item_row: ItemDisplayRow = get_or_create_item_row(item)

			item_row.update_count(item_count)
			item_row.update_change_rate(item_change_rate)

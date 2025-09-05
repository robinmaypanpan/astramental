class_name ResourceDisplay extends Control

## Setup the game
func setup_game() -> void:
	update_counts()

## An instance of a single display row for a single item.
@export var item_display_row: PackedScene
@export var _PlayerStateContainer: Node 

@onready var _item_display_list := %ItemDisplayList

## Mapping from item type -> instantiated item display row.
var _item_type_to_row_dict: Dictionary[Item.Type, Node]

func _ready() -> void:
	# set up an item display row for every item type
	for type in Item.Type.values():
		var new_row := item_display_row.instantiate()
		new_row.item_type = type
		_item_display_list.add_child(new_row)
		# add new item display row to the dictionary
		_item_type_to_row_dict[type] = new_row

## Update the counts of all items to their current resource amounts. Must be called manually for the resource numbers to update.
func update_counts() -> void:
	var my_player_number := ConnectionSystem.get_player(multiplayer.get_unique_id()).index
	var my_player_state: PlayerState = _PlayerStateContainer.get_child(my_player_number - 1)
	for type in Item.Type.values():
		var my_item_count := my_player_state.items[type]
		_item_type_to_row_dict[type].update_count(my_item_count)

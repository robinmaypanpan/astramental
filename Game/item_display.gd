extends MarginContainer

@export var item_display_row: PackedScene

@onready var _item_display_list := %ItemDisplayList
@onready var _player_states := %PlayerStates

var _item_type_to_row_dict: Dictionary[Item.Type, Node]

func _ready() -> void:
	for type in Item.Type.values():
		var new_row := item_display_row.instantiate()
		new_row.item_type = type
		_item_display_list.add_child(new_row)
		_item_type_to_row_dict[type] = new_row

func update_counts() -> void:
	var my_player_number := ConnectionSystem.get_player(multiplayer.get_unique_id()).index
	var my_player_state: PlayerState = _player_states.get_child(my_player_number - 1)
	for type in Item.Type.values():
		var my_item_count := my_player_state.items[type]
		_item_type_to_row_dict[type].update_count(my_item_count)

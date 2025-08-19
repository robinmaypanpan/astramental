extends MarginContainer

@onready var _PlayerStates := %PlayerStates
@onready var _ItemDisplay := %ItemDisplay

func _on_cheat_items_add_items(item_type: Item.Type, amount: int) -> void:
	print("received signal add_items(%s, %s)" % [item_type, amount])
	_PlayerStates.add_item(item_type, amount)
	_ItemDisplay.update_counts()

extends MarginContainer

@onready var _PlayerStates := %PlayerStates
@onready var _ItemDisplay := %ItemDisplay
@onready var _World := owner
@onready var _BoardHolder := %BoardHolder

@onready var _SeedText := %SeedText

func _on_cheat_items_add_items(item_type: Item.Type, amount: int) -> void:
	print("received signal add_items(%s, %s)" % [item_type, amount])
	_PlayerStates.add_item(item_type, amount)
	_ItemDisplay.update_counts()

@rpc("any_peer", "call_local", "reliable")
func _regen_player_boards() -> void:
	for player_board in _BoardHolder.get_children():
		player_board.queue_free()
	
	if multiplayer.is_server():
		randomize()
		_World.set_up_game.rpc(randi())

func _on_regen_world_button_pressed() -> void:
	_regen_player_boards.rpc()


func _on_world_game_ready() -> void:
	_SeedText.text = "Seed: %d" % _World.world_seed

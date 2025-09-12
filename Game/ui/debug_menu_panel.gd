extends Control

@export var _World : Node
@export var _ResourceDisplay : ResourceDisplay
@export var _Asteroid : Asteroid

@onready var _SeedText := %SeedText

## Actually add items to the given player
func _on_cheat_items_add_items(item_type: Types.Item, amount: int) -> void:
	print("received signal add_items(%s, %s)" % [item_type, amount])
	var player_id: int = multiplayer.get_unique_id()
	Model.increase_item_count(player_id, item_type, amount)

## Reset and regenerate the player boards with a new random seed
@rpc("any_peer", "call_local", "reliable")
func _regen_player_boards() -> void:
	for player_board in _Asteroid.c():
		player_board.queue_free()
	
	if multiplayer.is_server():
		randomize()
		# this call will emit game_ready, which will update the seed text
		_World.set_up_game.rpc(randi())

func _on_regen_world_button_pressed() -> void:
	_regen_player_boards.rpc()

## Update seed text when the game is ready, as we don't know the world seed until then.
func _on_world_game_ready() -> void:
	_SeedText.text = "Seed: %d" % _World.world_seed

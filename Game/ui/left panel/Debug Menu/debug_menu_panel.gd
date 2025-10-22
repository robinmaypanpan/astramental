extends Control

@export var resource_display: ResourceDisplay

@onready var seed_text := %SeedText


## Actually add items to the given player
func _on_cheat_items_add_items(item_type: Types.Item, amount: int) -> void:
	print("received signal add_items(%s, %s)" % [item_type, amount])
	var player_id: int = multiplayer.get_unique_id()
	Model.increase_item_count(player_id, item_type, amount)


## Handler for the regen world button
func _on_regen_world_button_pressed() -> void:
	Model.regenerate()


## Update seed text when the game is ready, as we don't know the world seed until then.
func _on_world_game_ready() -> void:
	seed_text.text = "Seed: %d" % Model.world_seed

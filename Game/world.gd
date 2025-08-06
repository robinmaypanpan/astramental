extends Control

@export var BoardHolder : Node
@export var PlayerBoard : PackedScene

func _ready() -> void:
	print(
		"%s (%s) says the players are %s" % [
			multiplayer.get_unique_id(),
			Globals.player_name,
			ConnectionSystem.players,
	])
	var your_board := PlayerBoard.instantiate()
	print("instantiated your_board")
	your_board.OwnerId = multiplayer.get_unique_id()
	your_board.OwnerName = Globals.player_name
	BoardHolder.add_child(your_board)
	print("added board to tree")

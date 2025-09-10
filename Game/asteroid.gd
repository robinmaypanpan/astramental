class_name Asteroid extends Control

@onready var _BoardHolder := %BoardHolder

@export var _Model: GameModel

func get_player_boards() -> Array[Node]:
	return _BoardHolder.get_children()
	
func add_player_board(board:Control) -> void:	
	_BoardHolder.add_child(board)

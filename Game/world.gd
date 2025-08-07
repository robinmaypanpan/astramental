extends Control

@export var BoardHolder : Node
@export var PlayerBoard : PackedScene

@onready var _GameState := %GameState

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
	
	if multiplayer.is_server():
		_GameState.example_int = 42

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("My game state is " + str(_GameState.example_int))
		if multiplayer.is_server():
			_GameState.example_int += 1

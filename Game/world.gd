extends Control

@export var BoardHolder : Node
@export var PlayerBoard : PackedScene

var num_players_ready := 0

@onready var _GameState := %GameState

func add_player_board(player_id: int, player_name: String) -> void:
	var board = PlayerBoard.instantiate()
	board.OwnerId = player_id
	board.OwnerName = player_name
	BoardHolder.add_child(board)

@rpc("call_local", "reliable")
func set_up_game(world_seed: int) -> void:
	seed(world_seed)

	var players = ConnectionSystem.players.duplicate()
	players[multiplayer.get_unique_id()] = Globals.player_name

	var sorted_player_ids = players.keys()
	sorted_player_ids.sort()

	for player_id in sorted_player_ids:
		var player_name = players[player_id]
		add_player_board(player_id, player_name)

@rpc("any_peer", "call_local", "reliable")
func register_ready() -> void:
	assert(multiplayer.is_server())
	num_players_ready += 1
	var total_num_players = ConnectionSystem.players.size() + 1
	
	if num_players_ready >= total_num_players:
		set_up_game.rpc(randi())

func _ready() -> void:
	print(
		"%s (%s) says the players are %s" % [
			multiplayer.get_unique_id(),
			Globals.player_name,
			ConnectionSystem.players,
	])
	if multiplayer.is_server():
		_GameState.example_int = 42

	register_ready.rpc_id(1)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("My game state is " + str(_GameState.example_int))
		if multiplayer.is_server():
			_GameState.example_int += 1

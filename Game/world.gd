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

	var player_ids = ConnectionSystem.get_player_id_list()

	for player_id in player_ids:
		var player = ConnectionSystem.get_player(player_id)
		add_player_board(player.index, player.name)

## Actually starts the game on the server
func start_game():
	assert(multiplayer.is_server())
	_GameState.example_int = 42
	set_up_game.rpc(randi())

@rpc("any_peer", "call_local", "reliable")
func register_ready() -> void:
	assert(multiplayer.is_server())
	num_players_ready += 1
	var total_num_players = ConnectionSystem.get_num_players()
	
	if num_players_ready >= total_num_players:
		start_game()

func _ready() -> void:
	if ConnectionSystem.is_not_running_network():
		ConnectionSystem.host_server()
		start_game()

	register_ready.rpc_id(1)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("My game state is " + str(_GameState.example_int))
		if multiplayer.is_server():
			_GameState.example_int += 1

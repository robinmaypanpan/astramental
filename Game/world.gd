extends Control

@export var BoardHolder : Node
@export var PlayerBoard : PackedScene

var num_players_ready := 0

@onready var _GameState := %GameState
@onready var _PlayerStates := %PlayerStates
@onready var _PlayerSpawner := %PlayerSpawner
@onready var _ItemDisplay := %ItemDisplay

func _ready() -> void:
	if ConnectionSystem.is_not_running_network():
		ConnectionSystem.host_server()
		start_game()

	register_ready.rpc_id(1)

	
func add_player_board(player_id: int) -> void:
	var board = PlayerBoard.instantiate()
	board.owner_id = player_id
	BoardHolder.add_child(board)

@rpc("call_local", "reliable")
func set_up_game(world_seed: int) -> void:
	seed(world_seed)
	
	var player_ids = ConnectionSystem.get_player_id_list()

	for player_id in player_ids:
		var player = ConnectionSystem.get_player(player_id)
		add_player_board(player_id)
	
	_ItemDisplay.update_counts()

## Actually starts the game on the server
func start_game():
	assert(multiplayer.is_server())
	_GameState.example_int = 42
	
	var player_ids = ConnectionSystem.get_player_id_list()

	for player_id in player_ids:
		_PlayerStates.add_state(player_id)
	
	set_up_game.rpc(randi())

## Register that this particular player is ready to start the game
@rpc("any_peer", "call_local", "reliable")
func register_ready() -> void:
	# TODO: Move this to connection system.
	assert(multiplayer.is_server())
	num_players_ready += 1
	var total_num_players = ConnectionSystem.get_num_players()
	
	if num_players_ready >= total_num_players:
		start_game()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_PlayerStates.add_item(Item.Type.COPPER, 10)
		_ItemDisplay.update_counts()

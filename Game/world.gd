extends Control

@export var BoardHolder : Node
@export var PlayerBoard : PackedScene
@export var MineLayer : PackedScene

# game board properties
@export var NumCols: int
@export var LayerThickness: int
@export var SkyHeight: int
@export var TileMapScale: int

var num_players_ready := 0
var _player_boards: Dictionary[int, Node]

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
	board.NumCols = NumCols
	board.LayerThickness = LayerThickness
	board.SkyHeight = SkyHeight
	board.TileMapScale = TileMapScale

	BoardHolder.add_child(board)
	_player_boards[player_id] = board

func init_ores_for_each_player(player_ids: Array[int]) -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in player_ids:
		ores_for_each_player[player_id] = []
	return ores_for_each_player


func generate_all_ores(player_ids: Array[int]) -> void:
	for layer_num in range(Ores.get_num_mine_layers()):
		var layer_gen_data := Ores.get_layer_generation_data(layer_num)
		var background_rock := layer_gen_data.background_rock
		var ores_for_each_player := init_ores_for_each_player(player_ids)
		var players_not_chosen_yet := player_ids.duplicate()

		# for each ore generation data in this layer
		for ore_gen_data in layer_gen_data.ores:
			if ore_gen_data.generate_for_all_players:
				# if it's for all players, add it for all players
				for player_id in player_ids:
					ores_for_each_player[player_id].append(ore_gen_data)
			else:
				# otherwise, assign it to a player that hasn't gotten a random ore yet
				players_not_chosen_yet.shuffle()
				var random_player: int = players_not_chosen_yet.pop_back()
				ores_for_each_player[random_player].append(ore_gen_data)
				# if we've assigned a random ore to each player at least once, do it again
				if players_not_chosen_yet.size() == 0:
					players_not_chosen_yet = player_ids.duplicate()
		
		# actually generate and add the ore boards to each player
		for player_id in player_ids:
			var mine_layer = MineLayer.instantiate()
			mine_layer.num_rows = LayerThickness
			mine_layer.num_cols = NumCols
			mine_layer.tile_map_scale = TileMapScale
			_player_boards[player_id].add_mine_layer(mine_layer)

			var player_ore_gen_data := ores_for_each_player[player_id]
			mine_layer.generate_ores(background_rock, player_ore_gen_data)


@rpc("call_local", "reliable")
func set_up_game(world_seed: int) -> void:
	seed(world_seed)
	
	var player_ids = ConnectionSystem.get_player_id_list()

	for player_id in player_ids:
		var player = ConnectionSystem.get_player(player_id)
		add_player_board(player_id)

	generate_all_ores(player_ids)	
	
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
		pass

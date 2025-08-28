extends Control

@export var PlayerBoard : PackedScene
@export var MineLayer : PackedScene

# game board properties
@export var NumCols: int
@export var LayerThickness: int
@export var SkyHeight: int
@export var TileMapScale: int

var num_players_ready := 0
var world_seed: int
var _player_boards: Dictionary[int, Node]
var _player_ids: Array[int]

@onready var _BoardHolder := %BoardHolder
@onready var _GameState := %GameState
@onready var _PlayerStates := %PlayerStates
@onready var _PlayerSpawner := %PlayerSpawner
@onready var _ItemDisplay := %ItemDisplay

## Emitted when the game is finished generating all ores and is ready to start playing.
signal game_ready()

func _ready() -> void:
	if ConnectionSystem.is_not_running_network():
		ConnectionSystem.host_server()
		start_game()

	register_ready.rpc_id(1)

## Given a player id, instantiate and add a board whose owner is the given player.
func add_player_board(player_id: int) -> void:
	var board = PlayerBoard.instantiate()

	board.owner_id = player_id
	board.NumCols = NumCols
	board.LayerThickness = LayerThickness
	board.SkyHeight = SkyHeight
	board.TileMapScale = TileMapScale

	_BoardHolder.add_child(board)
	_player_boards[player_id] = board

## Set up the dictionary to associate an empty array to each player id in the game.
func _init_ores_for_each_player() -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in _player_ids:
		ores_for_each_player[player_id] = []
	return ores_for_each_player

## Generate the mine layers for all players by instantiating and adding individual mine layer scenes to each player board.
func generate_all_ores() -> void:
	seed(world_seed)

	for layer_num in range(Ores.get_num_mine_layers()):
		var layer_gen_data := Ores.get_layer_generation_data(layer_num)
		var background_rock := layer_gen_data.background_rock
		var ores_for_each_player := _init_ores_for_each_player()
		var players_not_chosen_yet := _player_ids.duplicate()

		# for each ore generation data in this layer
		for ore_gen_data in layer_gen_data.ores:
			if ore_gen_data.generate_for_all_players:
				# if it's for all players, add it for all players
				for player_id in _player_ids:
					ores_for_each_player[player_id].append(ore_gen_data)
			else:
				# otherwise, assign it to a player that hasn't gotten a random ore yet
				players_not_chosen_yet.shuffle()
				var random_player: int = players_not_chosen_yet.pop_back()
				ores_for_each_player[random_player].append(ore_gen_data)
				# if we've assigned a random ore to each player at least once, do it again
				if players_not_chosen_yet.size() == 0:
					players_not_chosen_yet = _player_ids.duplicate()
		
		# actually generate and add the ore boards to each player
		for player_id in _player_ids:
			var mine_layer = MineLayer.instantiate()
			mine_layer.num_rows = LayerThickness
			mine_layer.num_cols = NumCols
			mine_layer.tile_map_scale = TileMapScale
			_player_boards[player_id].add_mine_layer(mine_layer)

			var player_ore_gen_data := ores_for_each_player[player_id]
			mine_layer.generate_ores(background_rock, player_ore_gen_data)


## Take the world seed from the server and initalize it and the world for all players.
@rpc("call_local", "reliable")
func set_up_game(server_world_seed: int) -> void:
	world_seed = server_world_seed
	_player_ids = ConnectionSystem.get_player_id_list()

	for player_id in _player_ids:
		add_player_board(player_id)

	generate_all_ores()

	game_ready.emit()
	
	_ItemDisplay.update_counts()

## Actually starts the game on the server
func start_game():
	assert(multiplayer.is_server())
	
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

## Set the UI to the building mode and show the building cursor
func _enter_build_mode(building: BuildingResource) ->void:
	# Spawn a ghost version of the building
	
	# show it in the correct position on the factory
	
	# listen for a mouse down so that we can finish placing it
	pass
	

## Returns true if we have the resources necessary to build this building
func _can_build(building: BuildingResource) -> bool:
	# We aren't handling this right now, so we can build anything
	# RPG: I'll put this together. Allison should focus on _enter_build_mdoe
	return true
	

func _on_build_miner_button_pressed() -> void:
	var miner_building: BuildingResource = preload("res://Game/data/buildings/miner.tres")
	if _can_build(miner_building):
		_enter_build_mode(miner_building)


func _on_build_solar_button_pressed() -> void:
	var solar_building: BuildingResource = preload("res://Game/data/buildings/solar_panel.tres")
	if _can_build(solar_building):
		_enter_build_mode(solar_building)

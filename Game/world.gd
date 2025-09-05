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
var _building_on_cursor: BuildingResource
var _in_build_mode: bool:
	get:
		return _building_on_cursor != null

@onready var _BoardHolder := %BoardHolder
@onready var _GameState := %GameState
@onready var _PlayerStates := %PlayerStates
@onready var _PlayerSpawner := %PlayerSpawner
@onready var _ItemDisplay := %ItemDisplay
@onready var _BuildMenu := %BuildMenu

## Emitted when the game is finished generating all ores and is ready to start playing.
signal game_ready()

func _ready() -> void:	
	if ConnectionSystem.is_not_running_network():
		# This is for when we are running the scene standalone
		UiUtils.get_ui_node()
		ConnectionSystem.host_server()
		start_game()

	register_ready.rpc_id(1)
	
	_BuildMenu.on_building_clicked.connect(_on_build_menu_building_clicked)

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

## Set the UI to the building mode and show the building cursor
func _enter_build_mode(building: BuildingResource) ->void:
	_building_on_cursor = building
	var cursor = UiUtils.get_cursor()
	if building != null:
		cursor.set_building_icon(building.factory_tile)
	else:
		cursor.set_building_icon(null)
	

## Returns true if we have the resources necessary to build this building
func _can_build(building: BuildingResource) -> bool:
	# We aren't handling this right now, so we can build anything
	# RPG: I'll put this together. Allison should focus on _enter_build_mdoe
	return true
	
func _on_build_menu_building_clicked(building: BuildingResource) -> void:
	if _can_build(building):
		_enter_build_mode(building)

enum MouseState {
	HOVERING,
	BUILDING,
	DELETING,
}

func in_same_board(pos1: TileMapPosition, pos2: TileMapPosition) -> bool:
	if pos1 and pos2:
		return pos1.tile_map == pos2.tile_map
	else:
		return false

# default value is null
var _mouse_tile_map_pos: TileMapPosition
var _mouse_state := MouseState.HOVERING

func _get_tile_map_pos() -> TileMapPosition:
	for player_id in _player_ids:
		var building_tile_maps = _player_boards[player_id].building_tile_maps
		for building_tile_map in building_tile_maps:
			if building_tile_map.mouse_inside_tile_map():
				var tile_position = building_tile_map.get_mouse_tile_map_coords()
				return TileMapPosition.new(building_tile_map, tile_position)
	return null

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_enter_build_mode(null)
		if _mouse_tile_map_pos:
			_mouse_tile_map_pos.tile_map.clear_ghost_building()
	elif Input.is_action_just_pressed("left_mouse_button"):
		_mouse_state = MouseState.BUILDING
	elif Input.is_action_just_pressed("right_mouse_button"):
		_mouse_state = MouseState.DELETING
	elif Input.is_action_just_released("either_mouse_button"):
		_mouse_state = MouseState.HOVERING
	
	var new_mouse_tile_map_pos = _get_tile_map_pos()
	var new_tile_map
	var new_tile_pos
	if new_mouse_tile_map_pos:
		new_tile_map = new_mouse_tile_map_pos.tile_map
		new_tile_pos = new_mouse_tile_map_pos.tile_position

	# update ghost
	if _in_build_mode:
		if _mouse_tile_map_pos and not in_same_board(_mouse_tile_map_pos, new_mouse_tile_map_pos):
			var old_tile_map = _mouse_tile_map_pos.tile_map
			old_tile_map.clear_ghost_building()
		if new_mouse_tile_map_pos:
			new_tile_map.move_ghost_building(new_tile_pos, _building_on_cursor)

	# place buildings
	if new_mouse_tile_map_pos and _mouse_state != MouseState.HOVERING:
		if _in_build_mode and _mouse_state == MouseState.BUILDING and _can_build(_building_on_cursor):
			new_tile_map.place_building(new_tile_pos, _building_on_cursor)
		if _mouse_state == MouseState.DELETING: # don't need to be in build mode to remove buildings
			new_tile_map.delete_building(new_tile_pos)

	# update position
	_mouse_tile_map_pos = new_mouse_tile_map_pos

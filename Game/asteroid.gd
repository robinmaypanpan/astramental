class_name Asteroid extends Control

@onready var _BoardHolder := %BoardHolder

@export var Model: GameModel
@export var PlayerBoard : PackedScene

# game board properties
@export var num_cols: int = 10
@export var layer_thickness: int = 7
@export var sky_height: int = 300
@export var tile_map_scale: int = 2

var _player_boards: Dictionary[int, Node]

func _register_player_board(player_id: int, player_board: Node) -> void:
	_player_boards[player_id] = player_board

func _get_player_board(player_id: int) -> Node:
	return _player_boards[player_id]

func _get_tile_map(player_id: int) -> BuildingTileMap:
	return _get_player_board(player_id).PlayerTileMap

## Given a player id, instantiate and add a board whose owner is the given player.
func add_player_board(player_id: int) -> void:
	var board = PlayerBoard.instantiate()

	board.owner_id = player_id
	board.NumCols = num_cols
	board.LayerThickness = layer_thickness
	board.SkyHeight = sky_height
	board.TileMapScale = tile_map_scale

	_BoardHolder.add_child(board)
	_register_player_board(player_id, board)

## Set up the dictionary to associate an empty array to each player id in the game.
func _init_ores_for_each_player() -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in Model.player_ids:
		ores_for_each_player[player_id] = []
	return ores_for_each_player

## Generate the mine layers for all players by instantiating and adding individual mine layer scenes to each player board.
func generate_all_ores() -> void:
	seed(Model.world_seed)

	# layer 0 is factory layer. layer 1 is 1st mine layer
	for layer_num in range(1, Ores.get_num_mine_layers() + 1):
		var layer_gen_data := Ores.get_layer_generation_data(layer_num)
		var background_rock := layer_gen_data.background_rock
		var ores_for_each_player := _init_ores_for_each_player()
		var players_not_chosen_yet := Model.player_ids.duplicate()

		# for each ore generation data in this layer
		for ore_gen_data in layer_gen_data.ores:
			if ore_gen_data.generate_for_all_players:
				# if it's for all players, add it for all players
				for player_id in Model.player_ids:
					ores_for_each_player[player_id].append(ore_gen_data)
			else:
				# otherwise, assign it to a player that hasn't gotten a random ore yet
				players_not_chosen_yet.shuffle()
				var random_player: int = players_not_chosen_yet.pop_back()
				ores_for_each_player[random_player].append(ore_gen_data)
				# if we've assigned a random ore to each player at least once, do it again
				if players_not_chosen_yet.size() == 0:
					players_not_chosen_yet = Model.player_ids.duplicate()
		
		# actually fill in the ore for each player
		for player_id in Model.player_ids:
			var player_board = _get_player_board(player_id)
			var player_ore_gen_data := ores_for_each_player[player_id]
			player_board.generate_ores(background_rock, player_ore_gen_data, layer_num)

func generate_player_boards() -> void:
	for player_id in Model.player_ids:
		add_player_board(player_id)

	generate_all_ores()

func in_same_board(pos1: TileMapPosition, pos2: TileMapPosition) -> bool:
	if pos1 and pos2:
		return pos1.player_id == pos2.player_id
	else:
		return false

func _get_tile_map_pos() -> TileMapPosition:
	for player_id in Model.player_ids:
		var tile_map = _get_tile_map(player_id)
		if tile_map.mouse_inside_tile_map():
			var tile_position = tile_map.get_mouse_tile_map_coords()
			return TileMapPosition.new(player_id, tile_position)
	return null

func _get_tile_map_from_pos(pos: TileMapPosition) -> BuildingTileMap:
	var player_id = pos.player_id
	return _get_tile_map(player_id)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		UiModel.building_on_cursor = null # exit build mode
		if UiModel.mouse_tile_map_pos:
			_get_tile_map_from_pos(UiModel.mouse_tile_map_pos).clear_ghost_building()
	elif Input.is_action_just_pressed("left_mouse_button"):
		UiModel.mouse_state = MouseState.BUILDING
	elif Input.is_action_just_pressed("right_mouse_button"):
		UiModel.mouse_state = MouseState.DELETING
	elif Input.is_action_just_released("either_mouse_button"):
		UiModel.mouse_state = MouseState.HOVERING
	
	var new_mouse_tile_map_pos = _get_tile_map_pos()
	var new_tile_map
	var new_tile_pos
	if new_mouse_tile_map_pos:
		new_tile_map = _get_tile_map_from_pos(new_mouse_tile_map_pos)
		new_tile_pos = new_mouse_tile_map_pos.tile_position

	# update ghost
	if UiModel.in_build_mode:
		if UiModel.mouse_tile_map_pos and not in_same_board(UiModel.mouse_tile_map_pos, new_mouse_tile_map_pos):
			var old_tile_map = _get_tile_map_from_pos(UiModel.mouse_tile_map_pos)
			old_tile_map.clear_ghost_building()
		if new_mouse_tile_map_pos:
			new_tile_map.move_ghost_building(new_tile_pos, UiModel.building_on_cursor)

	# place buildings
	if new_mouse_tile_map_pos and UiModel.mouse_state != MouseState.HOVERING:
		if UiModel.in_build_mode and UiModel.mouse_state == MouseState.BUILDING and Model.can_build(UiModel.building_on_cursor):
			new_tile_map.place_building(new_tile_pos, UiModel.building_on_cursor)
		if UiModel.mouse_state == MouseState.DELETING: # don't need to be in build mode to remove buildings
			new_tile_map.delete_building(new_tile_pos)

	# update position
	UiModel.mouse_tile_map_pos = new_mouse_tile_map_pos

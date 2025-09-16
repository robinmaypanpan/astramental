class_name Asteroid
extends Control
## Contains all player board logic.

@export var player_board_scene: PackedScene

var _player_boards: Dictionary[int, Node]

@onready var board_holder := %BoardHolder


func _ready() -> void:
	AsteroidViewModel.update_ore_tilemaps.connect(_on_update_ore_tilemaps)
	AsteroidViewModel.update_buildings.connect(_on_update_buildings)


## Given a player id, instantiate and add a board whose owner is the given player.
func add_player_board(player_id: int) -> void:
	var board = player_board_scene.instantiate()

	board.owner_id = player_id

	board_holder.add_child(board)
	_register_player_board(player_id, board)


## Add all player boards and generate ores for them.
func generate_player_boards() -> void:
	for player_id in Model.player_ids:
		add_player_board(player_id)

	_generate_all_ores()


## Generate the mine layers for all players by instantiating and adding
## individual mine layer scenes to each player board.
func _generate_all_ores() -> void:
	seed(Model.world_seed)

	# layer 0 is factory layer. layer 1 is 1st mine layer
	for layer_num in range(1, WorldGenModel.get_num_mine_layers() + 1):
		var layer_gen_data := WorldGenModel.get_layer_generation_data(layer_num)
		var background_rock := layer_gen_data.background_rock
		var ores_for_each_player := _init_ores_for_each_player()
		var players_not_chosen_yet: Array[int] = Model.player_ids.duplicate()

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


func _register_player_board(player_id: int, player_board: Node) -> void:
	_player_boards[player_id] = player_board


func _get_player_board(player_id: int) -> Node:
	return _player_boards[player_id]


func _get_tile_map(player_id: int) -> BuildingTileMap:
	return _get_player_board(player_id).player_tile_map


## Set up the dictionary to associate an empty array to each player id in the game.
func _init_ores_for_each_player() -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in Model.player_ids:
		ores_for_each_player[player_id] = []
	return ores_for_each_player


func _in_same_board(pos1: TileMapPosition, pos2: TileMapPosition) -> bool:
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
		AsteroidViewModel.building_on_cursor = Types.Building.NONE  # exit build mode
		if AsteroidViewModel.mouse_tile_map_pos:
			_get_tile_map_from_pos(AsteroidViewModel.mouse_tile_map_pos).clear_ghost_building()
	elif Input.is_action_just_pressed("left_mouse_button"):
		AsteroidViewModel.mouse_state = MouseState.BUILDING
	elif Input.is_action_just_pressed("right_mouse_button"):
		AsteroidViewModel.mouse_state = MouseState.DELETING
	elif Input.is_action_just_released("either_mouse_button"):
		AsteroidViewModel.mouse_state = MouseState.HOVERING

	var new_mouse_tile_map_pos = _get_tile_map_pos()
	var new_tile_map
	var new_tile_pos
	if new_mouse_tile_map_pos:
		new_tile_map = _get_tile_map_from_pos(new_mouse_tile_map_pos)
		new_tile_pos = new_mouse_tile_map_pos.tile_position

	# update ghost
	if AsteroidViewModel.in_build_mode:
		if (
			AsteroidViewModel.mouse_tile_map_pos
			and not _in_same_board(AsteroidViewModel.mouse_tile_map_pos, new_mouse_tile_map_pos)
		):
			var old_tile_map = _get_tile_map_from_pos(AsteroidViewModel.mouse_tile_map_pos)
			old_tile_map.clear_ghost_building()
		if new_mouse_tile_map_pos:
			new_tile_map.move_ghost_building(new_tile_pos, AsteroidViewModel.building_on_cursor)

	# place buildings
	if new_mouse_tile_map_pos and AsteroidViewModel.mouse_state != MouseState.HOVERING:
		if (
			AsteroidViewModel.in_build_mode
			and AsteroidViewModel.mouse_state == MouseState.BUILDING
			and Model.can_build(AsteroidViewModel.building_on_cursor)
		):
			request_place_building(new_mouse_tile_map_pos, AsteroidViewModel.building_on_cursor)
		if AsteroidViewModel.mouse_state == MouseState.DELETING:
			# don't need to be in build mode to remove buildings
			request_remove_building(new_mouse_tile_map_pos)

	# update position
	AsteroidViewModel.mouse_tile_map_pos = new_mouse_tile_map_pos


## Look at the model and write the ores_layout to the player board tile maps so they are visible.
func _on_update_ore_tilemaps() -> void:
	for player_board in _player_boards.values():
		var tile_map: BuildingTileMap = player_board.player_tile_map
		var player_id: int = player_board.owner_id
		var start_y = WorldGenModel.get_mine_layer_start_y()
		var end_y = WorldGenModel.get_all_layers_end_y()
		for x in range(WorldGenModel.num_cols):
			for y in range(start_y, end_y):
				var ore = Model.get_ore_at(player_id, x, y)
				var atlas_coordinates = Ores.get_atlas_coordinates(ore)
				tile_map.set_background_tile(x, y, atlas_coordinates)


## Request the server to let you place a building at the given position.
func request_place_building(pos: TileMapPosition, building: Types.Building) -> void:
	# do client side pretend placement
	print("requesting place building from %d" % multiplayer.get_unique_id())
	# then actually request the server to place the building
	process_place_building.rpc_id(1, pos.player_id, pos.tile_position, building)


## On the server, determine if a building placement request should be allowed.
## If it should, actually place the building for both players.
@rpc("any_peer", "call_local", "reliable")
func process_place_building(
	player_id: int, tile_position: Vector2i, building: Types.Building
) -> void:
	print("processing place building from %d" % multiplayer.get_unique_id())
	var caller_id = multiplayer.get_remote_sender_id()
	if Model.can_build(building):
		Model.set_building_at.rpc(player_id, tile_position, building)


## Request the server to let you remove a building at the given position.
func request_remove_building(pos: TileMapPosition) -> void:
	# do client side pretend placement
	print("requesting delete building from %d" % multiplayer.get_unique_id())
	# then actually request the server to place the building
	process_remove_building.rpc_id(1, pos.player_id, pos.tile_position)


## On the server, determine if a building removal request should be allowed.
## If it should, actually remove the building for both players.
@rpc("any_peer", "call_local", "reliable")
func process_remove_building(
	player_id: int, tile_position: Vector2i
) -> void:
	print("processing remove building from %d" % multiplayer.get_unique_id())
	var caller_id = multiplayer.get_remote_sender_id()
	if Model.can_remove():
		Model.remove_building_at.rpc(player_id, tile_position)


## Look at the model and redraw all the buildings to the screen.
func _on_update_buildings() -> void:
	print("update buildings for %d" % multiplayer.get_unique_id())
	for player_board in _player_boards.values():
		var tile_map: BuildingTileMap = player_board.player_tile_map
		var player_id: int = player_board.owner_id
		tile_map.building_tiles.clear()
		for placed_building in Model.get_buildings(player_id):
			tile_map.place_building(placed_building.position, placed_building.type)

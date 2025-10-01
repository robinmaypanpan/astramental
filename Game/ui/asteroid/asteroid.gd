class_name Asteroid
extends Control
## Contains all player board logic.

@export var player_board_scene: PackedScene

## Map of player ids to nodes
var _player_boards: Dictionary[int, Node]

@onready var board_holder := %BoardHolder


func _ready() -> void:
	AsteroidViewModel.ore_layout_changed_this_frame.connect(_on_update_ore_tilemaps)
	AsteroidViewModel.building_layout_changed_this_frame.connect(_on_update_buildings)


## Given a player id, instantiate and add a board whose owner is the given player.
func add_player_board(player_id: int) -> void:	
	print("Adding player id %s" % [player_id])
	var board := player_board_scene.instantiate()

	board.owner_id = player_id

	board_holder.add_child(board)
	_register_player_board(player_id, board)


## Add all player boards and generate ores for them.
func generate_player_boards() -> void:
	print("Generating player boards")
	# Clear out the old player boards, if necessary
	for player_board in board_holder.get_children():
		board_holder.remove_child(player_board)
		player_board.queue_free()

	# Generate new player boards!
	for player_id in ConnectionSystem.get_player_id_list():
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
		var players_not_chosen_yet: Array[int] = ConnectionSystem.get_player_id_list().duplicate()

		# for each ore generation data in this layer
		for ore_gen_data in layer_gen_data.ores:
			if ore_gen_data.generate_for_all_players:
				# if it's for all players, add it for all players
				for player_id in ConnectionSystem.get_player_id_list():
					ores_for_each_player[player_id].append(ore_gen_data)
			else:
				# otherwise, assign it to a player that hasn't gotten a random ore yet
				players_not_chosen_yet.shuffle()
				var random_player: int = players_not_chosen_yet.pop_back()
				ores_for_each_player[random_player].append(ore_gen_data)
				# if we've assigned a random ore to each player at least once, do it again
				if players_not_chosen_yet.size() == 0:
					players_not_chosen_yet = ConnectionSystem.get_player_id_list().duplicate()

		# actually fill in the ore for each player
		for player_id in ConnectionSystem.get_player_id_list():
			var player_board := _get_player_board(player_id)
			var player_ore_gen_data := ores_for_each_player[player_id]
			player_board.generate_ores(background_rock, player_ore_gen_data, layer_num)


func _register_player_board(player_id: int, player_board: Node) -> void:	
	_player_boards[player_id] = player_board


func _get_player_board(player_id: int) -> Node:
	if _player_boards.has(player_id):
		return _player_boards[player_id]
	return null


## Set up the dictionary to associate an empty array to each player id in the game.
func _init_ores_for_each_player() -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in ConnectionSystem.get_player_id_list():
		ores_for_each_player[player_id] = []
	return ores_for_each_player
	

## Returns the grid coordinates the mouse is over
func _get_new_building_coordinates() -> TileMapPosition:
	var player_id:int = multiplayer.get_unique_id()
	var player_board := _get_player_board(player_id)
	if player_board and player_board.is_mouse_over_factory_or_mine():
		var tile_position: Vector2i = player_board.get_mouse_grid_position()
		return TileMapPosition.new(player_id, tile_position)
	return null


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		AsteroidViewModel.building_on_cursor = "" # exit build mode		
		var player_board := _get_player_board(multiplayer.get_unique_id())
		player_board.clear_ghost_building()
	elif Input.is_action_just_pressed("left_mouse_button"):
		AsteroidViewModel.mouse_state = MouseState.BUILDING
	elif Input.is_action_just_pressed("right_mouse_button"):
		AsteroidViewModel.mouse_state = MouseState.DELETING
	elif Input.is_action_just_released("either_mouse_button"):
		AsteroidViewModel.mouse_state = MouseState.HOVERING

	var new_building_position: TileMapPosition = _get_new_building_coordinates()

	# update ghost
	if AsteroidViewModel.in_build_mode:
		if (AsteroidViewModel.mouse_tile_map_pos):			
			print("Updating ghost")
			var player_board := _get_player_board(multiplayer.get_unique_id())
			player_board.clear_ghost_building()
			if new_building_position:
				var new_tile_pos: Vector2i = new_building_position.tile_position
				player_board.set_ghost_building(new_tile_pos.x, new_tile_pos.y, AsteroidViewModel.building_on_cursor)

	# place buildings
	if new_building_position and AsteroidViewModel.mouse_state != MouseState.HOVERING:
		if (
			AsteroidViewModel.in_build_mode
			and AsteroidViewModel.mouse_state == MouseState.BUILDING
			and Model.can_build(AsteroidViewModel.building_on_cursor)
		):
			request_place_building(new_building_position, AsteroidViewModel.building_on_cursor)
		if AsteroidViewModel.mouse_state == MouseState.DELETING:
			# don't need to be in build mode to remove buildings
			request_remove_building(new_building_position)

	# update position
	AsteroidViewModel.mouse_tile_map_pos = new_building_position


## Look at the model and write the ores_layout to the player board tile maps so they are visible.
func _on_update_ore_tilemaps() -> void:
	for player_board in _player_boards.values():
		var player_id: int = player_board.owner_id
		var start_y := WorldGenModel.get_mine_layer_start_y()
		var end_y := WorldGenModel.get_all_layers_end_y()
		for x in range(WorldGenModel.num_cols):
			for y in range(start_y, end_y):
				var ore: Types.Ore = Model.get_ore_at(player_id, x, y)
				player_board.set_ore_at(x, y, ore)


## Request the server to let you place a building at the given position.
func request_place_building(pos: TileMapPosition, building: String) -> void:
	# do client side pretend placement
	print("requesting place building from %d" % multiplayer.get_unique_id())
	# then actually request the server to place the building
	process_place_building.rpc_id(1, pos.player_id, pos.tile_position, building)


## On the server, determine if a building placement request should be allowed.
## If it should, actually place the building for both players.
@rpc("any_peer", "call_local", "reliable")
func process_place_building(
	player_id: int, tile_position: Vector2i, building: String
) -> void:
	print("processing place building from %d" % multiplayer.get_unique_id())
	var caller_id := multiplayer.get_remote_sender_id()
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
	var caller_id := multiplayer.get_remote_sender_id()
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
			tile_map.place_building(placed_building.position, placed_building.id)

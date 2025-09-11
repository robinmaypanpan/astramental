extends Control

@onready var _ResourceDisplay := %ResourceDisplay
@onready var _Asteroid := %Asteroid
@onready var _BuildMenu := %BuildMenu
@onready var _Model := %Model

var num_players_ready := 0

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



## Take the world seed from the server and initalize it and the world for all players.
@rpc("call_local", "reliable")
func set_up_game(server_world_seed: int) -> void:
	_Model.world_seed = server_world_seed

	_Asteroid.generate_player_boards()

	game_ready.emit()
	
	_ResourceDisplay.setup_game()

## Actually starts the game on the server
func start_game():
	assert(multiplayer.is_server())
	
	_Model.start_game()
	
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
	# cursor will automatically update when building_on_cursor is modified
	UiModel.building_on_cursor = building
	

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
	for player_id in _Model.player_ids:
		var building_tile_maps = _Model.player_boards[player_id].building_tile_maps
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
	if UiModel.in_build_mode:
		if _mouse_tile_map_pos and not in_same_board(_mouse_tile_map_pos, new_mouse_tile_map_pos):
			var old_tile_map = _mouse_tile_map_pos.tile_map
			old_tile_map.clear_ghost_building()
		if new_mouse_tile_map_pos:
			new_tile_map.move_ghost_building(new_tile_pos, UiModel.building_on_cursor)

	# place buildings
	if new_mouse_tile_map_pos and _mouse_state != MouseState.HOVERING:
		if UiModel.in_build_mode and _mouse_state == MouseState.BUILDING and _can_build(UiModel.building_on_cursor):
			new_tile_map.place_building(new_tile_pos, UiModel.building_on_cursor)
		if _mouse_state == MouseState.DELETING: # don't need to be in build mode to remove buildings
			new_tile_map.delete_building(new_tile_pos)

	# update position
	_mouse_tile_map_pos = new_mouse_tile_map_pos

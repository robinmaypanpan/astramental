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
	_Model.initialize_both_player_variables(server_world_seed)

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
	
func _on_build_menu_building_clicked(building: BuildingResource) -> void:
	if _Model.can_build(building):
		_enter_build_mode(building)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_enter_build_mode(null)
		if UiModel.mouse_tile_map_pos:
			UiModel.mouse_tile_map_pos.tile_map.clear_ghost_building()

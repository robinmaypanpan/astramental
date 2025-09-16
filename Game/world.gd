class_name GameWorld
extends Control

## Emitted when the game is finished generating all ores and is ready to start playing.
signal game_ready

var num_players_ready := 0

@onready var resource_display := %ResourceDisplay
@onready var asteroid := %Asteroid
@onready var left_panel := %LeftPanel


func _ready() -> void:
	if ConnectionSystem.is_not_running_network():
		# This is for when we are running the scene standalone
		UiUtils.get_ui_node()
		ConnectionSystem.host_server()
		start_game()

	_register_ready.rpc_id(1)

	left_panel.get_build_menu().on_building_clicked.connect(_on_build_menu_building_clicked)


## Take the world seed from the server and initalize it and the world for all players.
@rpc("call_local", "reliable")
func set_up_game(server_world_seed: int) -> void:
	Model.initialize_both_player_variables(server_world_seed)

	asteroid.generate_player_boards()
	
	## TODO: This should be in the model.
	game_ready.emit()


## Regenerates the world, such as in a debug situation
func regenerate():
	_regen_player_boards.rpc()


## Actually starts the game on the server
func start_game():
	assert(multiplayer.is_server())

	Model.start_game()

	set_up_game.rpc(randi())


## Set the UI to the building mode and show the building cursor
func _enter_build_mode(building: Types.Building) -> void:
	# cursor will automatically update when building_on_cursor is modified
	AsteroidViewModel.building_on_cursor = building


## Register that this particular player is ready to start the game
@rpc("any_peer", "call_local", "reliable")
func _register_ready() -> void:
	# TODO: Move this to connection system.
	assert(multiplayer.is_server())
	num_players_ready += 1
	var total_num_players := ConnectionSystem.get_num_players()

	if num_players_ready >= total_num_players:
		start_game()


## Reset and regenerate the player boards with a new random seed
@rpc("any_peer", "call_local", "reliable")
func _regen_player_boards() -> void:
	for player_board in asteroid._BoardHolder.get_children():
		player_board.queue_free()

	if multiplayer.is_server():
		randomize()
		# this call will emit game_ready, which will update the seed text
		set_up_game.rpc(randi())


func _on_build_menu_building_clicked(building: Types.Building) -> void:
	if Model.can_build(building):
		_enter_build_mode(building)

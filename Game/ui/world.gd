class_name GameWorld
extends Control

@onready var resource_display := %ResourceDisplay
@onready var asteroid := %Asteroid
@onready var left_panel := %LeftPanel


func _ready() -> void:
	if ConnectionSystem.is_not_running_network():
		# This is for when we are running the scene standalone
		UiUtils.get_ui_node()
		ConnectionSystem.host_server()

	left_panel.get_build_menu().on_building_clicked.connect(_on_build_menu_building_clicked)

	Model.game_ready.connect(_on_game_ready)

	Model.ui_loaded()


func _on_game_ready() -> void:
	asteroid.generate_player_boards()
	# TODO: remove this hack
	for player_id: int in ConnectionSystem.get_player_id_list():
		var player_state: PlayerState = Model.player_states.get_state(player_id)
		if multiplayer.is_server():
			player_state.ores.publish()


## Set the UI to the building mode and show the building cursor
func _enter_build_mode(building: String) -> void:
	# cursor will automatically update when building_on_cursor is modified
	AsteroidViewModel.building_on_cursor = building


func _on_build_menu_building_clicked(building: String) -> void:
	if Model.can_afford(building):
		_enter_build_mode(building)

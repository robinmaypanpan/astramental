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


## Set the UI to the building mode and show the building cursor
func _enter_build_mode(building: Types.Building) -> void:
	# cursor will automatically update when building_on_cursor is modified
	AsteroidViewModel.building_on_cursor = building


func _on_build_menu_building_clicked(building: Types.Building) -> void:
	if Model.can_build(building):
		_enter_build_mode(building)

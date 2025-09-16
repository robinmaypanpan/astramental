class_name LeftPanel extends Control

@export var world: GameWorld

@onready var resource_display := %ResourceDisplay
@onready var debug_menu_panel := %Debug
@onready var build_menu := %Build


func _ready() -> void:
	debug_menu_panel.world = world
	world.game_ready.connect(_on_game_ready)

## Returns the build menu
func get_build_menu() -> BuildMenu:
	return build_menu

## Setup the left panel at the start of a game
func _on_game_ready() -> void:
	resource_display.setup_game()

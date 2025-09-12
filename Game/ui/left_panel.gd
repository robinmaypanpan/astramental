class_name LeftPanel extends Control

@export var world: Node

@onready var resource_display := %ResourceDisplay
@onready var debug_menu_panel := %Debug
@onready var build_menu := %Build


func _ready() -> void:
	debug_menu_panel.world = world


## Setup the left panel at the start of a game
func setup_game() -> void:
	resource_display.setup_game()


## Returns the build menu
func get_build_menu() -> BuildMenu:
	return build_menu

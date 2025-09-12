class_name LeftPanel extends Control

@export var _World : Node

@onready var _ResourceDisplay := %ResourceDisplay
@onready var _DebugMenuPanel := %Debug
@onready var _BuildMenu := %Build

func _ready() -> void:
	_DebugMenuPanel.World = _World
	
## Setup the left panel at the start of a game
func setup_game() -> void:
	_ResourceDisplay.setup_game()

## Returns the build menu
func get_build_menu() -> BuildMenu:
	return _BuildMenu
	

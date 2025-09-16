class_name LeftPanel extends Control

@onready var resource_display := %ResourceDisplay
@onready var debug_menu_panel := %Debug
@onready var build_menu := %Build

## Returns the build menu
func get_build_menu() -> BuildMenu:
	return build_menu

@tool
extends EditorPlugin

var dock
var data: ResourceListData

func _enter_tree() -> void:
	# Grab the data file
	data = preload("res://resource_list_data.tres")
	
	# Initialization of the plugin goes here.
	# Load the dock scene and instantiate it.
	dock = preload("res://addons/resource_list/resource_list_dock.tscn").instantiate()
	dock.load_data(data)

	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	# Note that LEFT_UL means the left of the editor, upper-left dock.


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
	# Also erase the data from memory
	data.free()

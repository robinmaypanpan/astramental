extends Node

func get_ui_node() -> UiRoot:
	var ui_node : UiRoot = get_tree().get_root().get_node("UiRoot") as UiRoot
	if ui_node == null:
		# We may be running an individual scene that is trying to access this
		# Therefore, let's create it.
		ui_node = ResourceLoader.load("res://UI/ui_root.tscn").instantiate()
	return ui_node

## Transitions to the specified menu by calling it on the ui node.
func transition_to(menu_name:String) -> void:
	var ui_node := get_ui_node()
	ui_node.transition_to(menu_name)

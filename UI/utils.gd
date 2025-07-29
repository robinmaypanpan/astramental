extends Node

func get_ui_node() -> Ui:
	var ui_node : Ui = get_tree().get_root().get_node("Ui") as Ui
	if ui_node == null:
		# We may be running an individual scene that is trying to access this
		# Therefore, let's create it.
		ui_node = ResourceLoader.load("res://UI/utils.gd").instance()
	return ui_node

## Transitions to the specified menu by calling it on the ui node.
func transition_to(menu_name:String) -> void:
	var ui_node := get_ui_node()
	ui_node.transition_to(menu_name)

extends Node

## Transitions to the specified menu by calling it on the ui node.
func transition_to(menu_name:String) -> void:
	var ui_node : Ui = get_tree().get_root().get_node("Ui") as Ui
	ui_node.transition_to(menu_name)

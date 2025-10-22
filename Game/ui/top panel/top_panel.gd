extends Panel

func _ready() -> void:
	Globals.tooltip_target_changed.connect(on_tooltip_target_changed);
	
func on_tooltip_target_changed(control_node: Control):
	if control_node == null:
		%Title.text = "";
	else:
		%Title.text = control_node.name;

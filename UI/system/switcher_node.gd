## This is a special script that can be added to a container to ensure that
## only a single child widget is active at any given time.
class_name SwitcherNode extends Control

## This is the initial child to show as visible
@export var initial_child:Control

## Stores whatever node is currently active
var _current_visible_child: Control

func _ready() -> void:
	_current_visible_child = initial_child
	for child:Control in get_children():
		child.hide()
		child.visibility_changed.connect(_child_visibility_changed)
	initial_child.show()

func _child_visibility_changed() -> void:
	var new_visible_child:Control
	for child:Control in get_children():	
		if child != _current_visible_child and child.is_visible_in_tree():
			if new_visible_child != null:
				# Too many children are visible!
				child.hide()
			elif child.is_visible_in_tree():
				new_visible_child = child
	
	if new_visible_child != null:
		new_visible_child.show()
		_current_visible_child.hide()
		_current_visible_child = new_visible_child
			
	

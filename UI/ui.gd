class_name Ui extends Control

## A list of named menus that can be transitioned to/from
@export var Menus : Dictionary[String, PackedScene]

@onready var shroud_animation : AnimationPlayer = %AnimationPlayer
@onready var MenusContainer : Node = %MenusContainer

var current_node : Node

func _ready() -> void:
	transition_to("MainMenu")
	
	
func transition_to(menu_name: String) -> Node:
	# Identify the scene we're transitioning to
	var new_node : Node
	if Menus.has(menu_name):
		new_node = Menus[menu_name].instantiate()
	elif ResourceLoader.exists(menu_name):
		new_node = ResourceLoader.load(menu_name).instance()
	else:
		assert(false, "Menu " + menu_name + " not found")
		return null
	
	# Transition out of the current menu
	if current_node != null:
		var current_menu = current_node as Menu
		if current_menu != null:
			current_menu.starting_fade_out()
		shroud_animation.play("fade_to_black")
		await(shroud_animation.animation_finished)
		current_node.hide()
		current_node.queue_free()
		MenusContainer.remove_child(current_node)
		current_node = null
	
	# Transition to the new menu
	if new_node != null:
		current_node = new_node
		MenusContainer.add_child(new_node)
		new_node.show()
		shroud_animation.play_backwards("fade_to_black")
		await(shroud_animation.animation_finished)
		
		var new_menu = new_node as Menu
		if new_menu != null:
			new_menu.fade_in_complete()
		return new_node
		
	return null

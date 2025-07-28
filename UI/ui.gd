extends Control

# We should have a link to all of our possible UIs
# We will probably want to refactor this to use packed scenes int he future.
@onready var MainMenu : Node = %MainMenu
@onready var Lobby : Node = %Lobby
@onready var shroud_animation : AnimationPlayer = %AnimationPlayer

var current_scene : Node

func _ready() -> void:
	transition_to_scene(MainMenu)
	MainMenu.connection_estabilished.connect(on_connection_established)
	
func transition_to_scene(new_scene: Node):
	if current_scene != null:
		shroud_animation.play("fade_to_black")
		await(shroud_animation.animation_finished)
		current_scene.hide()
		current_scene = null
	
	current_scene = new_scene
	new_scene.show()
	shroud_animation.play_backwards("fade_to_black")
	
func on_connection_established():
	transition_to_scene(Lobby)

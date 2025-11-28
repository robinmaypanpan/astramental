class_name StateMachine
extends Node

@export var initial_state: State = null

## The current state for this state machine
var current_state: State


func _ready() -> void:
	var children := find_children("*", "State")
	for child: State in children:
		child.finished.connect(transition_state)
	var ready_state := get_initial_state()
	transition_state(ready_state.name, {"firstTime": true})


func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handleInput(event)


func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physicsUpdate(delta)


func transition_state(next_state: String, flags: Dictionary) -> void:
	var old_state: String = ""
	if current_state != null:
		old_state = current_state.name
		current_state.exit(next_state, flags)
		current_state = null

	# Wait for the scene to be ready before transitioning
	if flags.has("firstTime"):
		if not is_node_ready():
			await ready
		elif owner != null and not owner.is_node_ready():
			await owner.ready

	current_state = get_node(next_state)
	current_state.enter(old_state, flags)
	print_debug("transitions from: " + old_state + " to: " + current_state.name)


func get_initial_state() -> State:
	if initial_state != null:
		return initial_state
	else:
		return get_child(0)

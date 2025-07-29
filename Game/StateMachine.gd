extends Node
class_name StateMachine

var currentState : State
@export var initialState:State = null

func _ready() -> void:
	var children = find_children("*", "State")
	for child:State in children:
		child.finished.connect(transitionState)
	var readyState = getInitialState()
	transitionState(readyState.name, {"firstTime":true})

func getInitialState() -> State:
	if initialState != null:
		return initialState
	else:
		return get_child(0)

func _unhandled_input(event:InputEvent) -> void:
	if currentState != null:
		currentState.handleInput(event)


func _process(delta: float) -> void:
	if currentState != null:
		currentState.update(delta)

func _physics_process(delta: float) -> void:
	if currentState != null:
		currentState.physicsUpdate(delta)
	
func transitionState(nextState:String, flags:Dictionary) -> void:
	var oldState:String  = ""
	if currentState != null:
		oldState = currentState.name
		currentState.exit(nextState, flags)
		currentState = null
	if flags.has("firstTime"):
		await owner.ready
	currentState = get_node(nextState)
	currentState.enter(oldState, flags)
	print_debug("transitions from: " + oldState + " to: " + currentState.name)

	

# GdUnit generated TestSuite
class_name StateMachineTest
extends GdUnitTestSuite

@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")
# TestSuite generated from
# gdlint: disable=constant-name
const __source: String = "res://Utilities/StateMachine.gd"

# our mocks
var mock_state1: State
var mock_state2: State
var state_machine: StateMachine


func create_mock_state(mock_name: String) -> State:
	var mock_state = mock(State)
	mock_state.name = mock_name
	return mock_state


# Setup test data here
func before_test():
	# Create our mock states
	mock_state1 = create_mock_state("MockState1")
	mock_state2 = create_mock_state("MockState2")

	# Create our state machine
	state_machine = StateMachine.new()
	state_machine.name = "StateMachine"
	state_machine.add_child(mock_state1)
	state_machine.add_child(mock_state2)

	add_child(state_machine)  # Add to scene tree to initialize

	if not state_machine.is_node_ready():
		await state_machine.ready

	# Add a small delay to allow signal processing
	await get_tree().process_frame


# Cleanup test data here
func after_test():
	if state_machine:
		state_machine.queue_free()
		state_machine = null
	mock_state1 = null
	mock_state2 = null


func test_state_machine_initialization() -> void:
	# Verify that the state machine exists
	assert_object(state_machine).is_not_null()
	assert_bool(mock_state1.is_node_ready()).is_true()
	assert_bool(mock_state2.is_node_ready()).is_true()

	# Verify that the initial state is set to the first child when
	# none are specified
	assert_object(state_machine.current_state).is_not_null()
	assert_object(state_machine.current_state).is_same(mock_state1)

	verify(mock_state1).enter("", {"firstTime": true})


func test_transition_state() -> void:
	# Transition to mock_state2
	state_machine.transition_state("MockState2", {})

	# Verify that the current state is now mock_state2
	assert_object(state_machine.current_state).is_not_null()
	assert_object(state_machine.current_state).is_same(mock_state2)

	# Verify that exit was called on mock_state1 and enter on mock_state2
	verify(mock_state1).exit("MockState2", {})
	verify(mock_state2).enter("MockState1", {})


func test_finished_signal_triggers_transition() -> void:
	# Make sure we're on state 1
	assert_object(state_machine.current_state).is_not_null()
	assert_object(state_machine.current_state).is_same(mock_state1)

	# Emit the finished signal from mock_state1
	mock_state1.finished.emit("MockState2", {})

	await get_tree().process_frame

	# Verify that the current state is now mock_state2
	assert_object(state_machine.current_state).is_not_null()
	(
		assert_object(state_machine.current_state)
		. override_failure_message(
			(
				"expected current state to be %s, but it's %s"
				% [mock_state2.name, state_machine.current_state.name]
			)
		)
		. is_same(mock_state2)
	)

	# Verify that exit was called on mock_state1 and enter on mock_state2
	verify(mock_state1).exit("MockState2", {})
	verify(mock_state2).enter("MockState1", {})


func test_update_calls_update_only_on_current_state() -> void:
	# Call _process on the state machine
	var delta_time: float = 0.16
	state_machine._process(delta_time)

	# Verify that update was called on the current state
	verify(mock_state1, 1).update(delta_time)
	verify(mock_state2, 0).update(any_float())

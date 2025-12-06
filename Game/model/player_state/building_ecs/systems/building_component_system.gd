class_name BuildingComponentSystem
extends Node
## The base class for all building component systems.


## Reset the numbers used for calculations for this tick.
func _reset_numbers() -> void:
	assert(false, "derived class of BuildingComponentSystem doesn't define _reset_numbers")


## Update the player state based on the components this system uses.
func update(_component_manager: NewComponentManager, _player_state: PlayerState) -> void:
	assert(false, "derived class of BuildingComponentSystem doesn't define update")

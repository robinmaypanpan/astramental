class_name BuildingComponentSystem
extends Node
## The base class for all building component systems.

## The player state this system is associated with.
@export var player_state: PlayerState

## The component manager for this player state.
@onready var component_manager: NewComponentManager = %ComponentManager


## Reset the numbers used for calculations for this tick.
func _reset_numbers() -> void:
	assert(false, "derived class of BuildingComponentSystem doesn't define _reset_numbers")


## Update the player state based on the components this system uses.
func update() -> void:
	assert(false, "derived class of BuildingComponentSystem doesn't define update")

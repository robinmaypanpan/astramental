class_name BuildingEcs
extends Node
## The building entity-component system, which manages all building components, entity-component
## relationships, and systems. Only initialized and defined on the server.

## All the building components and building-component relationships.
@onready var component_manager: NewComponentManager = %ComponentManager

## All building component systems.
@onready var systems: Array[Node] = %Systems.get_children()

## Reference to the player state this ECS is responsible for.
@onready var player_state: PlayerState = get_parent()


## Update all systems that are a child of the Systems node. The order of the update is the order of
## the children.
func update() -> void:
	for system: Node in systems:
		system.update()


## Get the system with the given name.
func get_system(system_name: StringName) -> Node:
	for system: Node in systems:
		if system.get_script().get_global_name() == system_name:
			return system
	# else, nothing was found
	return null

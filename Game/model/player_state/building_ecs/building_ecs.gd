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
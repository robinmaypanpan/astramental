class_name BuildingEcs
extends Node
## The building entity-component system, which manages all building components, entity-component
## relationships, and systems. Only initialized and defined on the server.

## All the building components and building-component relationships.
var component_manager: NewComponentManager

## All building component systems.
@onready var systems: Array[Node] = get_children()

## Reference to the player state this ECS is responsible for.
@onready var player_state: PlayerState = get_parent()
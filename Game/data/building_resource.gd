class_name BuildingResource
extends Resource

## This enum is used to check if a building is placed in the factory 
## or in the mines
enum PlacementTypes {
	FACTORY,
	MINES
}

## User facing name for this building
@export var name: String = ""

## Unique id for this building.
@export var id: String

## User facing icon to display in purchase shop
@export var icon: AtlasTexture = null

## The unit per second energy drain caused by this building
@export var energy_drain: float = 0

## A list of item costs needed to build this building, if any
@export var item_costs: Array[ItemCost] = []

## Determines whether this building is placed in the factory or in the mines
@export var placement_destination: PlacementTypes = PlacementTypes.MINES

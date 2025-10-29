class_name BuildingResource
extends Resource

## User facing name for this building
@export var name: String = ""

## Unique id for this building.
@export var id: String

## User facing icon to display in purchase shop
@export var icon: AtlasTexture = null

## A list of item costs needed to build this building, if any
@export var item_costs: Array[ItemCost] = []

## Determines whether this building is placed in the factory or in the mines
@export var placement_destination: Types.Layer = Types.Layer.FACTORY

## Defines behavior of building through components.
@export var building_components: Array[BuildingComponentData]

## Describe the building to the user
@export var description: String


## Returns the associated component
func get_component(component_type: String) -> BuildingComponentData:
	for component in building_components:
		if component.type == component_type:
			return component
	return null

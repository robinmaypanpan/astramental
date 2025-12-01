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

## Used to determine the static refund value of this building.
@export_range(0.0, 1.0, 0.05, "or_greater") var refund_value: float = 1.0

## When true, the amount of heat reduces the value of the refund when
## selling this building
@export var heat_reduces_value: bool = true

## Returns the associated component
func get_component_data(component_type: String) -> BuildingComponentData:
	for component in building_components:
		if component.type == component_type:
			return component
	return null

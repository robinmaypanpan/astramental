class_name BuildingComponent
extends Object
## Instantiated component base class generated from corresponding BuildingComponentData.
## Contains runtime data for implementing the functionality of the component beyond
## just the data needed to describe the behavior.
## Used in BuildingEntity as well as ComponentManager.

## Reference to building entity this component is a part of.
var building_entity: BuildingEntity

## What kind of component this is. Needed to classify components.
var type: Types.BuildingComponent

## Reference to BuildingComponentData that this component is built from.
var _data: BuildingComponentData


func _init(bcd: BuildingComponentData, be: BuildingEntity, t: Types.BuildingComponent) -> void:
	_data = bcd
	building_entity = be
	type = t
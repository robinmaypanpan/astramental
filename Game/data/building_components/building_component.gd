class_name BuildingComponent
extends Object
## Instantiated component base class generated from corresponding BuildingComponentData.
## Contains runtime data for implementing the functionality of the component beyond
## just the data needed to describe the behavior.
## Used in BuildingEntity as well as ComponentManager.

## Unique id for this component
var unique_id: int

## Reference to building entity this component is a part of.
var building_entity: BuildingEntity

## What kind of component this is. Needed to classify components.
var type: String

## Reference to BuildingComponentData that this component is built from.
var _data: BuildingComponentData


func _init(
	in_unique_id: int,
	in_building_comp_data: BuildingComponentData,
	in_building_entity: BuildingEntity) -> void:
	# start function
	unique_id = in_unique_id
	_data = in_building_comp_data
	building_entity = in_building_entity
	type = get_script().get_global_name() # gets the class_name of the derived class


func serialize() -> Dictionary:
	var serialized_component: Dictionary = {}
	serialized_component["unique_id"] = unique_id
	serialized_component["building_entity"] = building_entity.unique_id
	serialized_component["type"] = type
	serialized_component["_data"] = _data.serialize()
	return serialized_component
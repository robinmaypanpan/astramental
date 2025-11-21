class_name BuildingComponentData
extends Resource
## Contains the data that describes the behavior of the building.
## Component data base class used in BuildingResource.

## What kind of component this is. Needed to classify components.
var type: String


func _init() -> void:
	type = get_script().get_global_name()  # gets the class_name of the derived class


## Make a BuildingComponent given this object, used when instantiating a BuildingEntity.
func make_component(_unique_id: int, _building_entity: BuildingEntity) -> BuildingComponent:
	# defined by derived classes: base class function should never be called.
	assert(false, "cannot make component for derived class that doesn't define how to make one")
	return null


## Convert component data to a dictionary that can be synchronized across the network.
func serialize() -> Dictionary:
	var serialized_component_data: Dictionary = {}
	serialized_component_data["type"] = type
	return serialized_component_data


## Take serialized component data from the network and turn it into real component data.
static func from_serialized(_serialized_component_data: Dictionary) -> BuildingComponentData:
	var component_data = BuildingComponentData.new()
	return component_data
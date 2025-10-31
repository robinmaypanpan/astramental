class_name BuildingComponentData
extends Resource
## Contains the data that describes the behavior of the building.
## Component data base class used in BuildingResource.

## What kind of component this is. Needed to classify components.
var type: String


## Make a BuildingComponent given this object, used when instantiating a BuildingEntity.
func make_component(_building_entity: BuildingEntity) -> BuildingComponent:
	# defined by derived classes: base class function should never be called.
	assert(false, "cannot make component for derived class that doesn't define how to make one")
	return null


func _init() -> void:
	type = get_script().get_global_name()  # gets the class_name of the derived class

class_name BuildingEntity
extends Resource
## Represents a building actually placed down in the Model.


## Which player placed this building.
var player_id: int
## The tile position of the building.
var position: Vector2i
## What building is here.
var id: String
## List of components keeping track of behavior
var components: Array[BuildingComponent]

func _init(pi, p, i: String):
	player_id = pi
	position = p
	id = i
	var building_resource = Buildings.get_by_id(i)
	for component_data in building_resource.building_components:
		var component = component_data.make_component(self)
		ComponentManager.add_component(component)

		components.append(component)

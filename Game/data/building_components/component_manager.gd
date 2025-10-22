extends Node
## Contains convenient list of all components for all buildings, sorted by component type.
## PlayerState calls init/remove_components_building() to handle components.
## Systems call get_components() when they want a list of all components of one type.

## Emitted when component is added.
signal component_added(component: BuildingComponent)

## Emitted when component is removed.
signal component_removed(component: BuildingComponent)

## Collection of all building components, sorted by type.
var _components_list: Dictionary[String, Array] = {}


## Register a new component with the ComponentManager.
func add_component(component: BuildingComponent) -> void:
	if not _components_list.has(component.type):
		_components_list[component.type] = []
	_components_list[component.type].append(component)
	component_added.emit(component)
	print("added component of type %s" % [component.type])
	print("components length is now %d" % _components_list[component.type].size())


## Initialize components by adding components to the BuildingEntity and the component list.
func init_components_building(building: BuildingEntity) -> void:
	var building_resource: BuildingResource = Buildings.get_by_id(building.id)
	for component_data: BuildingComponentData in building_resource.building_components:
		var component: BuildingComponent = component_data.make_component(building)
		add_component(component)
		building.components.append(component)


## Remove an existing component with the ComponentManager.
## Returns true if it was removed, and false if it wasn't.
func remove_component(component: BuildingComponent) -> bool:
	var index_to_remove: int = -1
	var components: Array = _components_list.get(component.type)
	if not components:
		return false

	for index: int in range(components.size()):
		var curr_component: BuildingComponent = components[index]
		if curr_component == component: # compare by reference is desired behavior
			index_to_remove = index

	if index_to_remove != -1:
		components.remove_at(index_to_remove)
		component_removed.emit(component)
		print("removed component of type %s" % [component.type])
		print("components length is now %d" % _components_list[component.type].size())
		return true
	else:
		return false


## Remove all components of a building from the component list.
func remove_components_building(building: BuildingEntity) -> void:
	for component: BuildingComponent in building.components:
		remove_component(component)


## Return an array of all components of the given type.
func get_components(type: String) -> Array:
	return _components_list.get(type, [])

class_name ComponentManager
extends Node
## Contains convenient list of all components for all buildings, sorted by component type.
## PlayerState calls init/remove_components_building() to handle components.
## Systems call get_components_by_type() when they want a list of all components of one type.

## Emitted when component is added.
signal component_added(component: BuildingComponent)

## Emitted when component is removed.
signal component_removed(component: BuildingComponent)

## Given building entity unique ID,
## what are the unique IDs of the building components of that building?
var _components_for_building: Dictionary[int, Array] = {}

## Collection of all building components.
var _components_list: Array[BuildingComponent] = []

## Each key of components_by_type is component.type, and the value is an array of unique ids to
## reference in the components_list.
var _components_by_type: Dictionary[String, Array] = {}

## List of array indices that are vacant in components_list.
## Used when inserting into components_list.
var _vacant_indices: Array[int] = []


## Initialize and add all components needed for the given building.
func add_components_building(building: BuildingEntity) -> void:
	var building_unique_id: int = building.unique_id
	_components_for_building[building_unique_id] = []

	var building_resource: BuildingResource = Buildings.get_by_id(building.building_id)

	for component_data: BuildingComponentData in building_resource.building_components:
		# add component to components_list
		var component_unique_id: int
		var component: BuildingComponent
		if not _vacant_indices.is_empty():
			component_unique_id = _vacant_indices.pop_back()
			component = component_data.make_component(component_unique_id, building)
			_components_list[component_unique_id] = component
		else:
			component_unique_id = _components_list.size()
			component = component_data.make_component(component_unique_id, building)
			_components_list.append(component)

		# add component to components_by_type
		if not _components_by_type.has(component.type):
			_components_by_type[component.type] = []
		_components_by_type[component.type].append(component_unique_id)

		# add component to components_for_building
		_components_for_building[building_unique_id].append(component_unique_id)

		component_added.emit(component)
		print_debug("added component of type %s, component id %d" % [component.type, component_unique_id])
		print_debug("component type length is now %d" % _components_by_type[component.type].size())


## Internal function to remove an existing component by its unique ID from the component manager.
func _remove_component(unique_id: int) -> void:
	if unique_id >= _components_list.size():
		return

	var removed_component = get_by_id(unique_id)
	_components_list[unique_id] = null
	_components_by_type[removed_component.type].erase(unique_id)
	# removing component from _components_for_building is done by remove_components_building
	_vacant_indices.append(unique_id)

	component_removed.emit(removed_component)
	print_debug("removed component of type %s, component id %d" % [removed_component.type, unique_id])
	print_debug("component type length is now %d" % _components_by_type[removed_component.type].size())


## Remove all components of the given building.
func remove_components_building(building: BuildingEntity) -> void:
	var building_unique_id = building.unique_id
	if not _components_for_building.has(building_unique_id):
		return

	var component_unique_ids_to_remove: Array = _components_for_building[building_unique_id]
	for component_unique_id: int in component_unique_ids_to_remove:
		_remove_component(component_unique_id)
	_components_for_building.erase(building_unique_id)


## Return an array of all components of the given type.
func get_components_by_type(type: String) -> Array:
	if _components_by_type.has(type):
		var components: Array[BuildingComponent] = []
		for unique_id: int in _components_by_type[type]:
			components.append(_components_list[unique_id])
		return components
	else:
		return []


## Return the array of all the components of the given building.
func get_components_of_building(building_unique_id: int) -> Array:
	if _components_for_building.has(building_unique_id):
		var components: Array[BuildingComponent] = []
		for component_unique_id: int in _components_for_building[building_unique_id]:
			components.append(_components_list[component_unique_id])
		return components
	else:
		return []


## Return the building component with the given unique id.
func get_by_id(component_unique_id: int) -> BuildingComponent:
	if component_unique_id < _components_list.size():
		return _components_list[component_unique_id]
	else:
		return null

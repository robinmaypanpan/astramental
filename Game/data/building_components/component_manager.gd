extends Node
## Contains convenient list of all components for all buildings, sorted by component type.
## PlayerState calls init/remove_components_building() to handle components.
## Systems call get_components() when they want a list of all components of one type.

## Emitted when component is added.
signal component_added(component: BuildingComponent)

## Emitted when component is removed.
signal component_removed(component: BuildingComponent)

## Collection of all building components.
var _components_list: Array[BuildingComponent]

## Each key of components_by_type is component.type, and the value is an array of unique ids to
## reference in the components_list.
var _components_by_type: Dictionary[String, Array]

## List of array indices that are vacant in components_list.
## Used when inserting into components_list.
var _vacant_indices: Array[int]


## Initialize components by adding components to the BuildingEntity and the component list.
func init_components_building(building: BuildingEntity) -> void:
	var building_resource: BuildingResource = Buildings.get_by_id(building.building_id)
	for component_data: BuildingComponentData in building_resource.building_components:
		# add component to components_list
		var unique_id: int
		var component: BuildingComponent
		if not _vacant_indices.is_empty():
			unique_id = _vacant_indices.pop_back()
			component = component_data.make_component(unique_id, building)
			_components_list[unique_id] = component
		else:
			unique_id = _components_list.size()
			component = component_data.make_component(unique_id, building)
			_components_list.append(component)

		# add component to components_by_type
		if not _components_by_type.has(component.type):
			_components_by_type[component.type] = []
		_components_by_type[component.type].append(unique_id)

		# add component to building's component list
		building.components.append(component)

		component_added.emit(component)
		print("added component of type %s, component id %d" % [component.type, unique_id])
		print("component type length is now %d" % _components_by_type[component.type].size())


## Remove an existing component with the ComponentManager.
## Returns true if it was removed, and false if it wasn't.
func remove_component(component: BuildingComponent) -> bool:
	var unique_id: int = component.unique_id
	if unique_id >= _components_list.size():
		assert(
			false,
			(
				"Attempting to remove component with unique id %d bigger than components_list.size() %d"
				% [unique_id, _components_list.size()]
			)
		)
		return false

	_components_list[unique_id] = null
	_components_by_type[component.type].erase(unique_id)
	_vacant_indices.append(unique_id)

	component_removed.emit(component)
	print("removed component of type %s, component id %d" % [component.type, unique_id])
	print("component type length is now %d" % _components_by_type[component.type].size())
	return true


## Remove all components of a building from the component list.
func remove_components_building(building: BuildingEntity) -> void:
	for component: BuildingComponent in building.components:
		remove_component(component)


## Return an array of all components of the given type.
func get_components(type: String) -> Array:
	if _components_by_type.has(type):
		var components = []
		for unique_id: int in _components_by_type[type]:
			components.append(_components_list[unique_id])
		return components
	else:
		return []


## Return the building component with the given unique id.
func get_by_id(unique_id: int) -> BuildingComponent:
	if unique_id < _components_list.size():
		return _components_list[unique_id]
	else:
		return null

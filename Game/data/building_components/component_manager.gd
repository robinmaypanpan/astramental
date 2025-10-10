class_name ComponentManager
## Contains convenient list of all components for all buildings, sorted by component type.
## Model and BuildingEntity _init() call add/remove_component to register new components
## with this.
## Systems call get_components() when they want a list of all components of one type.

## Collection of all building components, sorted by type.
static var _components_list: Dictionary[Types.BuildingComponent, Array] = {}

## Given a building component type, return it's actual name. Helper function for logging.
## TODO: move this somewhere else
static func get_type_name(type: int):
	return Types.BuildingComponent.keys()[type]


## Register a new component with the ComponentManager.
static func add_component(component: BuildingComponent) -> void:
	if not _components_list.has(component.type):
		_components_list[component.type] = []
	_components_list[component.type].append(component)
	print("added component of type %s" % [get_type_name(component.type)])
	print("components length is now %d" % _components_list[component.type].size())


## Remove an existing component with the ComponentManager.
## Returns true if it was removed, and false if it wasn't.
static func remove_component(component: BuildingComponent) -> bool:
	var index_to_remove = -1
	var components = _components_list.get(component.type)
	if not components:
		return false

	for index in range(components.size()):
		var curr_component = components[index]
		if curr_component == component: # compare by reference is desired behavior
			index_to_remove = index

	if index_to_remove != -1:
		components.remove_at(index_to_remove)
		print("removed component of type %s" % [get_type_name(component.type)])
		print("components length is now %d" % _components_list[component.type].size())
		return true
	else:
		return false


## Return an array of all components of the given type.
static func get_components(type: Types.BuildingComponent) -> Array:
	return _components_list.get(type, [])

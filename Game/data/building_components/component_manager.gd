class_name ComponentManager

static var _components_list: Dictionary[Types.BuildingComponent, Array] = {}

## TODO: move this somewhere else
static func get_type_name(type: int):
	return Types.BuildingComponent.keys()[type]


static func add_component(component: BuildingComponent) -> void:
	if not _components_list.has(component.type):
		_components_list[component.type] = []
	_components_list[component.type].append(component)
	print("added component of type %s" % [get_type_name(component.type)])
	print("components length is now %d" % _components_list[component.type].size())


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
		print("removed component of type %s" % Types.BuildingComponent.keys()[component.type])
		print("components length is now %d" % _components_list[component.type].size())
		return true
	else:
		return false


static func get_components(type: Types.BuildingComponent) -> Array:
	return _components_list[type]

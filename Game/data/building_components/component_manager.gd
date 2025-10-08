class_name ComponentManager

static var _components_list: Dictionary[Types.BuildingComponent, Array] = {}

static func add_component(component: BuildingComponent) -> int:
	if not _components_list.has(component.type):
		_components_list[component.type] = []
	_components_list[component.type].append(component)
	return _components_list[component.type].size() - 1 # return index of last element of array

static func get_components(type: Types.BuildingComponent) -> Array:
	return _components_list[type]

extends Node

## The path to the folder containing all building resources.
@export var path_to_buildings: String

## Mapping between unique string id and building resource.
var _buildings_dict: Dictionary[String, BuildingResource]


## Dynamically build list of buildings by getting everything in the buildings directory.
func _ready() -> void:
	var paths := ResourceLoader.list_directory(path_to_buildings)
	for path in paths:
		var building_path: String = "%s/%s" % [path_to_buildings, path]
		var building_resource: BuildingResource = load(building_path)
		var building_id: String = building_resource.id
		# if the key already exists, then building_id is not unique and we must crash
		if _buildings_dict.has(building_id):
			assert(false, "buildings '%s' and '%s' both have id '%s'" % [
				building_resource.name,
				_buildings_dict[building_id].name,
				building_id
			])
		_buildings_dict[building_id] = building_resource


## Returns the building resource associated with this building id. Returns null if it doesn't exist.
func get_by_id(building_id: String) -> BuildingResource:
	return _buildings_dict.get(building_id)


## Return a list of all BuildingResources.
func get_all_buildings() -> Array[BuildingResource]:
	return _buildings_dict.values()

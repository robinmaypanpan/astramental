extends Node

@export var _buildings_dict: Dictionary[Types.Building, BuildingResource]

func get_icon(building_type: Types.Building) -> AtlasTexture:
	if building_type != Types.Building.NONE:
		return _buildings_dict[building_type].icon
	else:
		return null

func get_atlas_coords(building_type: Types.Building) -> Vector2i:
	if building_type != Types.Building.NONE:
		return _buildings_dict[building_type].atlas_coordinates
	else:
		return Vector2i(-1, -1)

## Returns the building resource associated with this building type
func get_building_resource(building_type: Types.Building) -> BuildingResource:
	if building_type != Types.Building.NONE:
		return _buildings_dict[building_type]
	else:
		return null

## Returns a string that represents the user displayable name of this building
func get_building_name(building_type: Types.Building) -> String:
	var building_resource: BuildingResource = get_building_resource(building_type)
	if building_resource != null:
		return building_resource.name
	else:
		return ""

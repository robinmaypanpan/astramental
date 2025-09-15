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

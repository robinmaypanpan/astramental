extends MarginContainer

class_name BuildingTileMap

## Defines whether this layer is a factory layer or mine layer
@export var layer_type: Types.Layer
@export var tile_map_scale: int
@export_range(0.0, 1.0) var ghost_building_opacity: float

@onready var _BackgroundTiles: TileMapLayer = %BackgroundTiles
@onready var _BuildingTiles: TileMapLayer = %BuildingTiles
@onready var _GhostBuildingTiles: TileMapLayer = %GhostBuildingTiles

var _ghost_building_position: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	var tile_scale = Vector2i(tile_map_scale, tile_map_scale) 
	_BackgroundTiles.scale = tile_scale
	_BuildingTiles.scale = tile_scale
	_GhostBuildingTiles.scale = tile_scale
	# all tiles placed on the GhostBuildingTiles will be transparent
	_GhostBuildingTiles.modulate = Color(1.0, 1.0, 1.0, ghost_building_opacity)
	

func set_background_tile(x: int, y: int, atlas_coordinates: Vector2i) -> void:
	_BackgroundTiles.set_cell(Vector2i(x, y), 0, atlas_coordinates)

func clear_ghost_building():
	if _ghost_building_position != Vector2i(-1, -1):
		_GhostBuildingTiles.erase_cell(_ghost_building_position)

func move_ghost_building(pos: Vector2i, building: BuildingResource):
	clear_ghost_building()
	_ghost_building_position = pos
	_GhostBuildingTiles.set_cell(pos, 0, building.atlas_coordinates)

func place_building(pos: Vector2i, building: BuildingResource):
	_BuildingTiles.set_cell(pos, 0, building.atlas_coordinates)

func delete_building(pos: Vector2i):
	_BuildingTiles.erase_cell(pos)

func mouse_inside_tile_map() -> bool:
	var global_mouse_position = _BuildingTiles.get_global_mouse_position()
	return get_global_rect().has_point(global_mouse_position)

func get_mouse_tile_map_coords() -> Vector2i:
	var global_mouse_position = _BuildingTiles.get_global_mouse_position()
	var local_mouse_position = _BuildingTiles.to_local(global_mouse_position)
	return _BuildingTiles.local_to_map(local_mouse_position)

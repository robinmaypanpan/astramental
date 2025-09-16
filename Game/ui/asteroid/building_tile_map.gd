class_name BuildingTileMap
extends MarginContainer

@export_range(0.0, 1.0) var ghost_building_opacity: float

var tile_map_scale: int
var layer_thickness: int
var _ghost_building_position: Vector2i = Vector2i(-1, -1)

@onready var background_tiles: TileMapLayer = %BackgroundTiles
@onready var building_tiles: TileMapLayer = %BuildingTiles
@onready var ghost_building_tiles: TileMapLayer = %GhostBuildingTiles


func _ready() -> void:
	var tile_scale := Vector2i(tile_map_scale, tile_map_scale)
	background_tiles.scale = tile_scale
	building_tiles.scale = tile_scale
	ghost_building_tiles.scale = tile_scale
	# all tiles placed on the GhostBuildingTiles will be transparent
	ghost_building_tiles.modulate = Color(1.0, 1.0, 1.0, ghost_building_opacity)


func set_background_tile(x: int, y: int, atlas_coordinates: Vector2i) -> void:
	background_tiles.set_cell(Vector2i(x, y), 0, atlas_coordinates)


func clear_ghost_building():
	if _ghost_building_position != Vector2i(-1, -1):
		ghost_building_tiles.erase_cell(_ghost_building_position)


func move_ghost_building(pos: Vector2i, building_id: String):
	clear_ghost_building()
	_ghost_building_position = pos
	var atlas_coords := Buildings.get_by_id(building_id).atlas_coordinates
	ghost_building_tiles.set_cell(pos, 0, atlas_coords)


func place_building(pos: Vector2i, building_id: String):
	var atlas_coords := Buildings.get_by_id(building_id).atlas_coordinates
	building_tiles.set_cell(pos, 0, atlas_coords)


func delete_building(pos: Vector2i):
	building_tiles.erase_cell(pos)


func mouse_inside_tile_map() -> bool:
	var global_mouse_position := building_tiles.get_global_mouse_position()
	return get_global_rect().has_point(global_mouse_position)


func get_mouse_tile_map_coords() -> Vector2i:
	var global_mouse_position := building_tiles.get_global_mouse_position()
	var local_mouse_position := building_tiles.to_local(global_mouse_position)
	return building_tiles.local_to_map(local_mouse_position)

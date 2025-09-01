extends MarginContainer

class_name BuildingTileMap

## Defines whether this layer is a factory layer or mine layer
@export var layer_type: Layer.Type
@export var tile_map_scale: int
@export_range(0.0, 1.0) var ghost_building_opacity: float

@onready var _BackgroundTiles: TileMapLayer = %BackgroundTiles
@onready var _BuildingTiles: TileMapLayer = %BuildingTiles
@onready var _GhostBuildingTiles: TileMapLayer = %GhostBuildingTiles

func _ready() -> void:
	var tile_scale = Vector2i(tile_map_scale, tile_map_scale) 
	_BackgroundTiles.scale = tile_scale
	_BuildingTiles.scale = tile_scale
	_GhostBuildingTiles.scale = tile_scale
	# all tiles placed on the GhostBuildingTiles will be transparent
	_GhostBuildingTiles.modulate = Color(1.0, 1.0, 1.0, ghost_building_opacity)

func set_background_tile(x: int, y: int, atlas_coordinates: Vector2i) -> void:
	_BackgroundTiles.set_cell(Vector2i(x, y), 0, atlas_coordinates)

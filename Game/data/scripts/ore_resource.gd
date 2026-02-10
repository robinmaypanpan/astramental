class_name OreResource
extends Resource

## User facing atlas texture from which to extract tiles
@export var icon: AtlasTexture = null
## Deprecated: DO NOT USE
@export var atlas_coordinates: Vector2i
## The item that the ore should yield when mined.
@export var item_yield: Types.Item
## Display name of this ore
@export var display_name: String
## Description of this ore
@export var description: String

var _iconCache: Array[AtlasTexture] = []

## Returns a tile
func get_icon_for_level(level: int, index: int) -> AtlasTexture:
	if _iconCache.is_empty():
		_load_icon_cache()
	var num_tiles_per_level: int = floor(icon.get_size().x / 32.0)
	var tile_idx: int = ((level - 1) * num_tiles_per_level + index)
	return _iconCache[tile_idx]

## Loads the icon cache
func _load_icon_cache():
	var num_tiles_per_level: int = floor(icon.get_size().x / 32.0)
	var num_levels: int = floor(icon.get_size().y / 32.0)
	for level in range(num_levels):
		for tile_idx in range(num_tiles_per_level):
			var tile_texture: AtlasTexture = AtlasTexture.new()
			tile_texture.atlas = icon
			tile_texture.region = Rect2(Vector2i(tile_idx, level) * 32, Vector2i(32, 32))
			_iconCache.append(tile_texture)

class_name OreResource
extends Resource

## User facing atlas texture from which to extract tiles
@export var atlas: AtlasTexture = null
## The item that the ore should yield when mined.
@export var item_yield: Types.Item
## Display name of this ore
@export var display_name: String
## Description of this ore
@export var description: String

var _icon_cache: Array[AtlasTexture] = []

func get_num_variations_per_level() -> int:
	return floor(atlas.get_size().x / 32.0)

## Returns a tile
func get_icon_for_level(level: int, variation: int) -> AtlasTexture:
	if _icon_cache.is_empty():
		_load_icon_cache()
	var num_variations_per_level: int = get_num_variations_per_level()
	var variation_idx: int = ((level - 1) * num_variations_per_level + variation)
	return _icon_cache[variation_idx]

## Loads the atlas cache
func _load_icon_cache():
	var num_variations_per_level: int = get_num_variations_per_level()
	var num_levels: int = floor(atlas.get_size().y / 32.0)
	for level in range(num_levels):
		for variation_idx in range(num_variations_per_level):
			var tile_texture: AtlasTexture = AtlasTexture.new()
			tile_texture.atlas = atlas
			tile_texture.region = Rect2(Vector2i(variation_idx, level) * 32, Vector2i(32, 32))
			_icon_cache.append(tile_texture)

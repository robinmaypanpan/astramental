class_name OreResource
extends Resource

## User facing icon to display in the game grid
@export var icon: AtlasTexture = null
## The coordinates in the tileset that correspond to the correct tile image.
@export var atlas_coordinates: Vector2i
## The item that the ore should yield when mined.
@export var item_yield: Types.Item

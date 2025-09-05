extends Object

class_name TileMapPosition
## Which index in the player board's building_tile_maps corresponds to the BuildingTileMap the cursor is on
var tile_map: BuildingTileMap
## Which tile are we on in that BuildingTileMap
var tile_position: Vector2i

func _init(tm, tp):
	tile_map = tm
	tile_position = tp
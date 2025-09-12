class_name TileMapPosition
extends Object

## which player's board are we over
var player_id: int
## Which tile are we on in that board
var tile_position: Vector2i

func _init(pi, tp):
	player_id = pi
	tile_position = tp

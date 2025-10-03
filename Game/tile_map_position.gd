class_name PlayerGridPosition
extends Object

## which player's board?
var player_id: int

## Which tile on that board?
var tile_position: Vector2i


func _init(pi, tp):
	player_id = pi
	tile_position = tp

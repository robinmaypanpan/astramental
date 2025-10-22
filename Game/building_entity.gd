class_name BuildingEntity
extends Object
## Represents a building actually placed down in the Model.

## Which player placed this building.
var player_id: int
## The tile position of the building.
var position: Vector2i
## What building is here.
var id: String
## List of components keeping track of behavior.
var components: Array[BuildingComponent]

func _init(in_player_id: int, in_position: Vector2i, in_id: String):
	player_id = in_player_id
	position = in_position
	id = in_id
	# components will be initialized by player state

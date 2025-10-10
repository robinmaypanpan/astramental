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

func _init(pi, p, i: String):
	player_id = pi
	position = p
	id = i
	# components will be initialized by player state
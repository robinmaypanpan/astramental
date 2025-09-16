class_name PlacedBuilding
extends Resource
## Represents a building actually placed down in the Model.

## The tile position of the building.
var position: Vector2i
## What building is here.
var id: String

func _init(p, t):
	position = p
	id = t

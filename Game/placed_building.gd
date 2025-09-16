class_name PlacedBuilding
extends Resource
## Represents a building actually placed down in the Model.

## The tile position of the building.
var position: Vector2i
## What type of building is here.
var type: Types.Building

func _init(p, t):
	position = p
	type = t

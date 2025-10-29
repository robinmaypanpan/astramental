class_name HeatData
extends Object
## Data used to store heat information about one specific building in the model.

## Position of this building.
var position: Vector2i

## How much heat does this building have.
var heat: float

## How much heat can this building hold.
var heat_capacity: float


func _init(new_position: Vector2i, new_heat: float, new_heat_capacity: float) -> void:
	position = new_position
	heat = new_heat
	heat_capacity = new_heat_capacity
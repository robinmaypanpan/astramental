class_name PlacedBuilding
extends Resource

var position: Vector2i
var type: Types.Building

func _init(p, t):
    position = p
    type = t
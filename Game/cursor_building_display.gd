extends MarginContainer

@export var offset: Vector2
@export_range(1.0, 5.0) var building_scale: float

@onready var _BuildingDisplay: TextureRect = %BuildingDisplay

func _ready() -> void:
	scale = Vector2(building_scale, building_scale)

func _process(delta):
	var mouse_position := get_viewport().get_mouse_position()
	var offset_position = mouse_position + offset
	position = offset_position

## called by World to update the building cursor when clicking to select a building type
func set_cursor_building(building: BuildingResource):
	if building:
		_BuildingDisplay.texture = building.factory_tile
	else:
		_BuildingDisplay.texture = null

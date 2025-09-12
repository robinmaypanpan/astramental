extends SubViewport

class_name Cursor

@onready var _BuildingIcon := %BuildingIcon

func _update_cursor_image():
	await RenderingServer.frame_post_draw
	Input.set_custom_mouse_cursor(get_texture().get_image(), Input.CursorShape.CURSOR_ARROW)

func _ready() -> void:
	AsteroidViewModel.building_on_cursor_changed.connect(update_building_icon)
	_update_cursor_image()

func update_building_icon():
	var building = AsteroidViewModel.building_on_cursor
	if building:
		# can't access building icon if building is null
		_BuildingIcon.texture = building.icon
	else:
		_BuildingIcon.texture = null
	_update_cursor_image()

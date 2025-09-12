class_name Cursor
extends SubViewport

@onready var build_icon := %BuildingIcon


func _ready() -> void:
	AsteroidViewModel.building_on_cursor_changed.connect(update_building_icon)
	_update_cursor_image()


func _update_cursor_image():
	await RenderingServer.frame_post_draw
	Input.set_custom_mouse_cursor(get_texture().get_image(), Input.CursorShape.CURSOR_ARROW)


func update_building_icon():
	var building = AsteroidViewModel.building_on_cursor
	if building:
		# can't access building icon if building is null
		build_icon.texture = building.icon
	else:
		build_icon.texture = null
	_update_cursor_image()

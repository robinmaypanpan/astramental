extends SubViewport

class_name Cursor

@onready var _BuildingIcon := %BuildingIcon

func _update_cursor_image():
	await RenderingServer.frame_post_draw
	Input.set_custom_mouse_cursor(get_texture().get_image(), Input.CursorShape.CURSOR_ARROW)

func _ready() -> void:
	_update_cursor_image()

func set_building_icon(building_icon: AtlasTexture):
	_BuildingIcon.texture = building_icon
	_update_cursor_image()

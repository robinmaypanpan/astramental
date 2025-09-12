extends Node

# subscribed to by cursor
signal building_on_cursor_changed()
# subscribed to by asteroid
signal update_ore_tilemaps()

var building_on_cursor: BuildingResource:
	get:
		return building_on_cursor
	set(building):
		building_on_cursor = building
		building_on_cursor_changed.emit()

var in_build_mode: bool:
	get:
		return building_on_cursor != null

var mouse_state := MouseState.HOVERING
# default value is null
var mouse_tile_map_pos: TileMapPosition

## Whether the ores_layout in Model was updated this frame.
var ores_layout_dirty: bool = false

func _ready():
	Model.ores_layout_updated.connect(_on_ores_layout_updated)

func _process(_delta: float) -> void:
	if ores_layout_dirty:
		update_ore_tilemaps.emit()

func _on_ores_layout_updated():
	ores_layout_dirty = true

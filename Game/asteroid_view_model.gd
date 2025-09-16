extends Node

# subscribed to by cursor
signal building_on_cursor_changed()
# subscribed to by asteroid
signal update_ore_tilemaps()
# subscribed to by asteroid
signal update_buildings()

var building_on_cursor: Types.Building:
	get:
		return building_on_cursor
	set(building):
		building_on_cursor = building
		building_on_cursor_changed.emit()

var in_build_mode: bool:
	get:
		return building_on_cursor != Types.Building.NONE

var mouse_state := MouseState.HOVERING
# default value is null
var mouse_tile_map_pos: TileMapPosition

## Whether the ores_layout in Model was updated this frame.
var ores_layout_dirty: bool = false
## Whether the buildings list in Model was updated this frame.
var buildings_dirty: bool = false


func _ready():
	Model.ores_layout_updated.connect(_on_ores_layout_updated)
	Model.buildings_updated.connect(_on_buildings_updated)


func _process(_delta: float) -> void:
	if ores_layout_dirty:
		update_ore_tilemaps.emit()
		ores_layout_dirty = false
	if buildings_dirty:
		update_buildings.emit()
		buildings_dirty = false


func _on_ores_layout_updated():
	ores_layout_dirty = true


func _on_buildings_updated():
	buildings_dirty = true
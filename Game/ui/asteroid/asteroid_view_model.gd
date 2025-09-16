extends Node

# subscribed to by cursor
signal building_on_cursor_changed()
# Emitted when the ore layout changes, subscribed to by asteroid
signal ore_layout_changed_this_frame()
# Emitted when the list of buildings for either player changes, subscribed to by asteroid
signal building_layout_changed_this_frame()

var building_on_cursor: String:
	get:
		return building_on_cursor
	set(building):
		building_on_cursor = building
		building_on_cursor_changed.emit()

var in_build_mode: bool:
	get:
		return building_on_cursor != ""

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


## since this is UI updating, use _process instead of _physics_process
func _process(_delta: float) -> void:
	if ores_layout_dirty:
		ore_layout_changed_this_frame.emit()
		ores_layout_dirty = false
	if buildings_dirty:
		building_layout_changed_this_frame.emit()
		buildings_dirty = false


func _on_ores_layout_updated():
	ores_layout_dirty = true


func _on_buildings_updated():
	buildings_dirty = true

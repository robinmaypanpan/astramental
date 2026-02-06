extends Node

## subscribed to by cursor
signal building_on_cursor_changed
## Emitted when the ore layout changes, subscribed to by asteroid
signal ore_layout_changed_this_frame
## Emitted when the list of buildings for either player changes, subscribed to by asteroid
signal building_layout_changed_this_frame
## Emitted when heat stuff changed this frame, subscribed to by asteroid
signal heat_changed_this_frame

## used by the UI to indicate what's currently supposed to be on the cursor
var building_on_cursor: String:
	get:
		return building_on_cursor
	set(building):
		building_on_cursor = building
		building_on_cursor_changed.emit()

## Returns true when we're in build mode and the UI should react appropriately.
var in_build_mode: bool:
	get:
		return building_on_cursor != ""

## Stores the current state of the mouse
var mouse_state := MouseState.HOVERING

# Position that the mouse is currently positioned over
var mouse_hover_grid_position: Vector2i = Vector2i(-1, -1)

## Whether the ores_layout in Model was updated this frame.
var ores_layout_dirty: bool = false

## Whether the buildings list in Model was updated this frame.
var buildings_dirty: bool = false

## Whether the heat on buildings in Model was updated this frame.
var heat_dirty: bool = false


func _ready():
	Model.game_ready.connect(_on_game_ready)

	Model.heat_data_updated.connect(_on_heat_data_updated)


# since this is UI updating, use _process instead of _physics_process
func _process(_delta: float) -> void:
	if ores_layout_dirty:
		ore_layout_changed_this_frame.emit()
		ores_layout_dirty = false
	if buildings_dirty:
		building_layout_changed_this_frame.emit()
		buildings_dirty = false
	if heat_dirty:
		heat_changed_this_frame.emit()
		heat_dirty = false


func _on_ores_layout_updated():
	ores_layout_dirty = true


func _on_buildings_updated():
	buildings_dirty = true


func _on_heat_data_updated():
	heat_dirty = true


func _on_game_ready():
	var player_ids = ConnectionSystem.get_player_id_list()
	for player_id in player_ids:
		var player_state: PlayerState = Model.player_states.get_state(player_id)
		player_state.buildings.changed.connect(_on_buildings_updated)
		player_state.ores.changed.connect(_on_ores_layout_updated)

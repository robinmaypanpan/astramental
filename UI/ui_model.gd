extends Node

var building_on_cursor: BuildingResource:
	get:
		return building_on_cursor
	set(building):
		building_on_cursor = building
		building_on_cursor_changed.emit()

var in_build_mode: bool:
	get:
		return building_on_cursor != null

# subscribed to by Cursor
signal building_on_cursor_changed()

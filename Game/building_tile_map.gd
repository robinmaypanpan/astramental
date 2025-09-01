extends MarginContainer

class_name BuildingTileMap

## Defines whether this layer is a factory layer or mine layer
@export var layer_type: Layer.Type
@export var tile_map_scale: int
@export_range(0.0, 1.0) var ghost_building_opacity: float

@onready var _BackgroundTiles: TileMapLayer = %BackgroundTiles
@onready var _BuildingTiles: TileMapLayer = %BuildingTiles
@onready var _GhostBuildingTiles: TileMapLayer = %GhostBuildingTiles

signal tile_pressed(tile_map: BuildingTileMap, tile_map_position: Vector2i, mouse_button: MouseButton)
var _last_tile_position: Vector2i = Vector2i(-1, -1)
var _mouse_button_used: MouseButton

func _ready() -> void:
	var tile_scale = Vector2i(tile_map_scale, tile_map_scale) 
	_BackgroundTiles.scale = tile_scale
	_BuildingTiles.scale = tile_scale
	_GhostBuildingTiles.scale = tile_scale
	# all tiles placed on the GhostBuildingTiles will be transparent
	_GhostBuildingTiles.modulate = Color(1.0, 1.0, 1.0, ghost_building_opacity)
	

func set_background_tile(x: int, y: int, atlas_coordinates: Vector2i) -> void:
	_BackgroundTiles.set_cell(Vector2i(x, y), 0, atlas_coordinates)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("either_mouse_button"):
		# check if the input is inside our bounding box, as this actually fires for every instance of this tilemap whether it is inside the bounding box or not
		# the reason we don't use mouse_entered and mouse_exited signals is due to these signals not firing if the control moves and the mouse doesn't
		var global_mouse_position = _BuildingTiles.get_global_mouse_position()
		if get_global_rect().has_point(global_mouse_position):
			# convert the mouse position to the coordinates inside the tilemap
			var local_mouse_position = _BuildingTiles.to_local(global_mouse_position)
			var tile_pos :=_BuildingTiles.local_to_map(local_mouse_position)
			# only send input events when the tile position under the cursor changes
			if _last_tile_position != tile_pos:
				_last_tile_position = tile_pos
				# the first event is a mousebutton event, telling us what button was clicked
				# following events are mousemotion events, which don't tell us what button is being clicked
				if event is InputEventMouseButton:
					_mouse_button_used = event.button_index

				tile_pressed.emit(self, tile_pos, _mouse_button_used)
				print("emitting tile_pressed(%s, %s)" % [tile_pos, _mouse_button_used])

	elif Input.is_action_just_released("either_mouse_button"):
		# reset last tile position in case they stop dragging and start dragging on the same position
		_last_tile_position = Vector2i(-1, -1)
		_mouse_button_used = MOUSE_BUTTON_NONE

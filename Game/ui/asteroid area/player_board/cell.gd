class_name Cell
extends Control

## Stores the position of this cell in its parent grid
var grid_position: Vector2i = Vector2i.ZERO

@onready var heat_indicator: ProgressBar = %HeatLevel
@onready var icon: TextureRect = %IconImage
@onready var background: TextureRect = %BackgroundImage
@onready var ghost: TextureRect = %GhostImage
@onready var overheated_cell_tint: ColorRect = %OverheatedCellTint

@export var overheated_tint_color: Color = Color(1, 0, 0, 0.625)
var transparent_tint_color: Color = Color(1, 1, 1, 0)


func _ready() -> void:
	icon.texture = null
	background.texture = null
	ghost.texture = null
	heat_indicator.visible = false
	heat_indicator.value = 0.0
	overheated_cell_tint.color = transparent_tint_color


func _on_mouse_entered() -> void:
	Globals.update_tooltip_target(self)


func _on_mouse_exited() -> void:
	Globals.clear_tooltip_target(self)


## Returns the player ID that owns this cell
func get_owning_player_id() -> int:
	var parent_board: CellularPlayerBoard = find_parent("PlayerBoard*") as CellularPlayerBoard
	assert(parent_board != null, "Cell is not a child of a CellularPlayerBoard")
	return parent_board.get_owning_player_id()


## Change the top layer for this cell for this cell
func set_icon(texture: Texture):
	icon.texture = texture


## Set the background texture for this cell
func set_background(texture: Texture):
	background.texture = texture


## Set the heat bar for this cell
func set_heat_bar(heat: float, heat_capacity: float):
	heat_indicator.max_value = heat_capacity
	heat_indicator.value = heat
	heat_indicator.visible = true


## Clear the heat bar for this cell
func clear_heat_bar() -> void:
	heat_indicator.visible = false
	heat_indicator.value = 0.0


## Set the overheated tint to a red tint if the building is overheated
func set_heat_state(heat_state: Types.HeatState) -> void:
	if heat_state == Types.HeatState.OVERHEATED:
		overheated_cell_tint.color = overheated_tint_color
	elif heat_state == Types.HeatState.RUNNING:
		overheated_cell_tint.color = transparent_tint_color


## set the ghost texture for this cell
func set_ghost(texture: Texture):
	ghost.texture = texture

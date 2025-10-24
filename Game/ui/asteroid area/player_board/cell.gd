class_name Cell
extends Control

## Stores the position of this cell in its parent grid
var grid_position: Vector2i = Vector2i.ZERO

@onready var heat_indicator: ProgressBar = %HeatLevel
@onready var icon: TextureRect = %IconImage
@onready var background: TextureRect = %BackgroundImage
@onready var ghost: TextureRect = %GhostImage


func _ready() -> void:
	icon.texture = null
	background.texture = null
	ghost.texture = null
	heat_indicator.visible = false
	heat_indicator.value = 0.0


func _on_mouse_entered() -> void:
	Globals.update_tooltip_target(self)


func _on_mouse_exited() -> void:
	Globals.clear_tooltip_target(self)


## Change the top layer for this cell for this cell
func set_icon(texture: Texture):
	icon.texture = texture


## Set the background texture for this cell
func set_background(texture: Texture):
	background.texture = texture


## Set the heat level for this cell
func set_heat(value: float):
	heat_indicator.value = value
	heat_indicator.visible = value > 0.0


## set the ghost texture for this cell
func set_ghost(texture: Texture):
	ghost.texture = texture

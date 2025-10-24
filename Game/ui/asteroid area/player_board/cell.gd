class_name Cell
extends Control

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
func set_icon(texture:Texture):
	icon.texture = texture

## Set the background texture for this cell
func set_background(texture:Texture):
	background.texture = texture

## Set the heat bar for this cell
func set_heat_bar(heat: float, heat_capacity: float):
	heat_indicator.max_value = heat_capacity
	heat_indicator.value = heat
	heat_indicator.visible = true

## Clear the heat bar for this cell
func clear_heat_bar() -> void:
	heat_indicator.visible = false

## set the ghost texture for this cell
func set_ghost(texture:Texture):
	ghost.texture = texture

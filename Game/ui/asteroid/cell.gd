class_name Cell
extends Control

@onready var heat_indicator: ProgressBar = %HeatLevel
@onready var icon: TextureRect = %IconImage
@onready var background: TextureRect = %BackgroundImage

func _ready() -> void:
	icon.texture = null
	background.texture = null
	heat_indicator.visible = false
	heat_indicator.value = 0.0

func set_icon(texture:Texture):
	icon.texture = texture

func set_background(texture:Texture):
	background.texture = texture
	
func set_heat(value:float):
	heat_indicator.value = value
	heat_indicator.visible = value > 0.0

extends Control

@onready var _Icon:TextureRect = %Icon
@onready var _CostText:Label = %CostText

func set_building(building: BuildingResource) -> void:
	_CostText.text = "$%f" % building.money_cost
	_Icon.texture = building.shop_icon

func _ready() -> void:
	pass

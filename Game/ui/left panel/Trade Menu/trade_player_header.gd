class_name TradePlayerHeader
extends Control

@export var sending_arrow: Texture
@export var receiving_arrow: Texture

@onready var trade_icon: TextureRect = %TradeIcon
@onready var player_text: Label = %PlayerText


func update_player(new_player_name: String) -> void:
	player_text.text = new_player_name


func update_trade_direction(trade_direction: Types.TradeDirection) -> void:
	if trade_direction == Types.TradeDirection.RECEIVING:
		trade_icon.icon = receiving_arrow
	elif trade_direction == Types.TradeDirection.SENDING:
		trade_icon.icon = sending_arrow
	else:
		assert(false, "unknown trade direction %s" % Types.TradeDirection.keys()[trade_direction])

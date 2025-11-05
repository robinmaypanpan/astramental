class_name TradePlayerHeader
extends Control

@onready var trade_icon: TextureRect = %TradeIcon
@onready var player_text: Label = %PlayerText


func update_player(new_player_name: String) -> void:
	player_text.text = new_player_name


func update_trade_icon(new_icon: Texture) -> void:
	trade_icon.texture = new_icon

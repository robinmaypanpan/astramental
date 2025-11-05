class_name TradeItemDetails
extends Control

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_trade_text: Label = %ItemTradeText


func update_item_icon(new_icon: Texture) -> void:
	item_icon.texture = new_icon


func update_item_production_text(new_trade_amount: float, new_net_production: float) -> void:
	item_trade_text.text = "%+.1f/s (net %+.1f/s)" % [new_trade_amount, new_net_production]

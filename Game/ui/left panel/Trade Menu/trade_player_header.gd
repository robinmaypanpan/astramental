class_name TradePlayerHeader
extends Control
## Row of trade tab specifying the player and which direction trade is flowing
## for the items below this.

## Texture for indicating this player is sending resources.
@export var sending_arrow: Texture

## Texture for indicating this player is receiving resources.
@export var receiving_arrow: Texture

@onready var trade_icon: TextureRect = %TradeIcon
@onready var player_text: Label = %PlayerText


## Update the shown player name to the given name.
func update_player(new_player_name: String) -> void:
	player_text.text = new_player_name


## Update the trade direction to the given one, changing the trade icon shown.
func update_trade_direction(trade_direction: Types.TradeDirection) -> void:
	if trade_direction == Types.TradeDirection.RECEIVING:
		trade_icon.icon = receiving_arrow
	elif trade_direction == Types.TradeDirection.SENDING:
		trade_icon.icon = sending_arrow
	else:
		assert(false, "unknown trade direction %s" % Types.TradeDirection.keys()[trade_direction])

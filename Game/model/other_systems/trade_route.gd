class_name TradeRoute
extends Object
## A trade route representing a single item being sent from one player to another.

## The id of this trade route.
var id: int

## The player sending resources.
var sending_player_id: int

## The player receiving resources.
var receiving_player_id: int

## The item that is being traded.
var item: Types.Item

## The amount of the item being traded.
var amount: float


func _init(
	new_id: int, new_sending_id: int, new_receiving_id: int, new_item: Types.Item, new_amount: float
) -> void:
	id = new_id
	sending_player_id = new_sending_id
	receiving_player_id = new_receiving_id
	item = new_item
	amount = new_amount

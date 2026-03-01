class_name TradeModel
extends SyncProperty
## Model for trade routes.

## All of the trade routes currently set up between players.
var trade_routes: Array[TradeRoute]

## The next internal id to be used for newly created trade routes.
var _next_trade_route_id: int = 0


func _ready() -> void:
	trade_routes = [] as Array[TradeRoute]


## Add a new trade route.
func add_trade_route(
	sending_player_id: int, receiving_player_id: int, item: Types.Item, amount: float
) -> void:
	assert(multiplayer.is_server())
	var new_trade_route: TradeRoute = TradeRoute.new(
		_next_trade_route_id, sending_player_id, receiving_player_id, item, amount
	)
	trade_routes.append(new_trade_route)
	_next_trade_route_id += 1


## Remove an existing trade route by its internal id.
func remove_trade_route(trade_route_id: int) -> void:
	assert(multiplayer.is_server())
	var index_to_remove: int = trade_routes.find_custom(
		func(elem): return elem.id == trade_route_id
	)
	if index_to_remove != -1:
		trade_routes.remove_at(index_to_remove)


## Find all trade routes where the receiving player is the given player id.
func get_routes_received_by_player(player_id: int) -> Array[TradeRoute]:
	return trade_routes.filter(func(elem): return elem.receiving_player_id == player_id)


## Find all trade routes where the sending player is the given player id.
func get_routes_sent_by_player(player_id: int) -> Array[TradeRoute]:
	return trade_routes.filter(func(elem): return elem.sending_player_id == player_id)


func serialize(value: Variant) -> PackedByteArray:
	# layout: (15 bytes)
    # - sending_player_id: 4 bytes
    # - receiving_player_id: 4 bytes
    # - item_id: 4 bytes
    # - id: 2 bytes
    # - item: 1 byte


func deserialize(bytes: PackedByteArray) -> Variant:
	pass


func not_equal(value1: Variant, value2: Variant) -> bool:
	pass

class_name TradeModel
extends SyncProperty
## Model for trade routes.

## The next internal id to be used for newly created trade routes.
var _next_trade_route_id: int = 0


func _ready() -> void:
	value_client = [] as Array[TradeRoute]


## Add a new trade route.
func add_trade_route(
	sending_player_id: int, receiving_player_id: int, item: Types.Item, amount: float
) -> void:
	assert(multiplayer.is_server())
	var new_trade_route: TradeRoute = TradeRoute.new(
		_next_trade_route_id, sending_player_id, receiving_player_id, item, amount
	)
	value_client.append(new_trade_route)
	_next_trade_route_id += 1


## Remove an existing trade route by its internal id.
func remove_trade_route(trade_route_id: int) -> void:
	assert(multiplayer.is_server())
	var index_to_remove: int = value_client.find_custom(
		func(elem): return elem.id == trade_route_id
	)
	if index_to_remove != -1:
		value_client.remove_at(index_to_remove)


## Find all trade routes where the receiving player is the given player id.
func get_routes_received_by_player(player_id: int) -> Array[TradeRoute]:
	return value_client.filter(func(elem): return elem.receiving_player_id == player_id)


## Find all trade routes where the sending player is the given player id.
func get_routes_sent_by_player(player_id: int) -> Array[TradeRoute]:
	return value_client.filter(func(elem): return elem.sending_player_id == player_id)


## Return all the trade routes for all players.
func get_all() -> Array[TradeRoute]:
	return value_client


func serialize(value: Variant) -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	var num_routes: int = value.size()
	bytes.resize(num_routes * 15)

	var offset: int = 0
	for trade_route: TradeRoute in value_client:
		_encode_trade_route(bytes, offset, trade_route)
		offset += 15

	return bytes


func deserialize(bytes: PackedByteArray) -> Variant:
	var new_trade_routes: Array[TradeRoute] = [] as Array[TradeRoute]

	var offset: int = 0
	var bytes_size: int = bytes.size()
	while offset < bytes_size:
		new_trade_routes.append(_decode_trade_route(bytes, offset))
		offset += 15

	return new_trade_routes


func not_equal(value1: Variant, value2: Variant) -> bool:
	if value1.size() != value2.size():
		return true

	for i in range(value1.size()):
		var trade_route_1: TradeRoute = value1[i]
		var trade_route_2: TradeRoute = value2[i]
		if TradeRoute.not_equal(trade_route_1, trade_route_2):
			return true

	return false


func _encode_trade_route(bytes: PackedByteArray, offset: int, trade_route: TradeRoute) -> void:
	# layout: (15 bytes)
	# - sending_player_id: 4 bytes
	# - receiving_player_id: 4 bytes
	# - amount: 4 bytes
	# - id: 2 bytes
	# - item: 1 byte
	bytes.encode_u32(offset, trade_route.sending_player_id)
	bytes.encode_u32(offset + 4, trade_route.receiving_player_id)
	bytes.encode_float(offset + 8, trade_route.amount)
	bytes.encode_u16(offset + 12, trade_route.id)
	bytes.encode_u8(offset + 14, trade_route.item)


func _decode_trade_route(bytes: PackedByteArray, offset: int) -> TradeRoute:
	var sending_player_id = bytes.decode_u32(offset)
	var receiving_player_id = bytes.decode_u32(offset + 4)
	var amount = bytes.decode_float(offset + 8)
	var id = bytes.decode_u16(offset + 12)
	var item = bytes.decode_u8(offset + 14)
	return TradeRoute.new(
		id,
		sending_player_id,
		receiving_player_id,
		item,
		amount,
	)

extends Node
## Maintains trade routes and updates resources based on trade routes.

## All of the trade routes currently set up between players.
var trade_routes: Array[TradeRoute]

## The next internal id to be used for newly created trade routes.
var _next_trade_route_id: int = 0


## code for testing adding trade route
# func _ready() -> void:
# 	Model.game_ready.connect(_on_game_ready_test)

# func _on_game_ready_test() -> void:
# 	if multiplayer.is_server():
# 		var player_ids = ConnectionSystem.get_player_id_list()
# 		if player_ids.size() > 1:
# 			var first_player = player_ids[0]
# 			var second_player = player_ids[1]
# 			add_trade_route(first_player, second_player, Types.Item.IRON, 1)


## Add a new trade route.
func add_trade_route(
	sending_player_id: int, receiving_player_id: int, item: Types.Item, amount: float
) -> void:
	_broadcast_add_trade_route.rpc(sending_player_id, receiving_player_id, item, amount)


## Remove an existing trade route by its internal id.
func remove_trade_route(trade_route_id: int) -> void:
	_broadcast_remove_trade_route.rpc(trade_route_id)


## Find all trade routes where the receiving player is the given player id.
func get_routes_received_by_player(player_id: int) -> Array[TradeRoute]:
	return trade_routes.filter(
		func(elem): return elem.receiving_player_id == player_id
	)


## Find all trade routes where the sending player is the given player id.
func get_routes_sent_by_player(player_id: int) -> Array[TradeRoute]:
	return trade_routes.filter(
		func(elem): return elem.sending_player_id == player_id
	)


## Update each players' resources based on the trade routes.
func update() -> void:
	var update_interval = Globals.settings.update_interval
	for trade_route: TradeRoute in trade_routes:
		var sending_player_id: int = trade_route.sending_player_id
		var receiving_player_id = trade_route.receiving_player_id
		var item: Types.Item = trade_route.item

		# amount to send capped by how much I have to send
		var sending_capacity: float = Model.get_item_count(sending_player_id, item)

		# amount to receive capped by how much space I have to receive
		var receiving_item_count: float = Model.get_item_count(receiving_player_id, item)
		var receiving_storage_cap: float = Model.get_storage_cap(receiving_player_id, item)
		var receiving_capacity: float = receiving_storage_cap - receiving_item_count

		# figure out amount to send
		var send_amount_per_sec: float = min(trade_route.amount, sending_capacity, receiving_capacity)
		if not is_zero_approx(send_amount_per_sec):
			var send_amount_per_tick: float = send_amount_per_sec * update_interval

			Model.increase_item_count(sending_player_id, item, -send_amount_per_tick)
			Model.increase_item_consumption(sending_player_id, item, send_amount_per_sec)
			Model.increase_item_count(receiving_player_id, item, send_amount_per_tick)
			Model.increase_item_production(receiving_player_id, item, send_amount_per_sec)


## Add a new trade route for all players.
@rpc("any_peer", "call_local", "reliable")
func _broadcast_add_trade_route(
	sending_player_id: int, receiving_player_id: int, item: Types.Item, amount: float
) -> void:
	var new_trade_route: TradeRoute = TradeRoute.new(
		_next_trade_route_id, sending_player_id, receiving_player_id, item, amount
	)
	trade_routes.append(new_trade_route)
	_next_trade_route_id += 1


## Remove an existing trade route by its internal id for all players.
@rpc("any_peer", "call_local", "reliable")
func _broadcast_remove_trade_route(trade_route_id: int) -> void:
	var index_to_remove: int = trade_routes.find_custom(
		func(elem): return elem.id == trade_route_id
	)
	if index_to_remove != -1:
		trade_routes.remove_at(index_to_remove)

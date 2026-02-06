class_name GameModel
extends Node
## This class contains accessors to the major state containers and data for
## the complete current state of the game

## Emitted when the game is finished setting up and is ready to start playing
signal game_ready
## Emitted when ores_layout in PlayerStates is updated.
signal ores_layout_updated
## Emitted when heat_data_list in PlayerStates is updated.
signal heat_data_updated
## Emitted for both players when the update tick is done.
signal tick_done

## The number of players seen as ready. Used to determine when it is okay to start the game
var num_players_ready := 0

@onready var player_states: PlayerStates = %PlayerStates
@onready var player_spawner := %PlayerSpawner
@onready var game_state := %GameState
@onready var world_gen_model: WorldGenModel = %WorldGenModel
@onready var _update_timer := %UpdateTimer

## Take the world seed from the server and initalize it and the world for all players.
@rpc("call_local", "reliable")
func initialize_clients(server_world_seed: int) -> void:
	world_gen_model.world_seed = server_world_seed

	player_states.generate_player_states()


## Launches the game on all clients
@rpc("call_local", "reliable")
func launch_game() -> void:
	game_ready.emit()


## Does any work that needs to be done now that the UI has loaded
func ui_loaded() -> void:
	if ConnectionSystem.is_not_running_network():
		_start_game()
	else:
		register_player_ready.rpc_id(1)


## Regenerates the world, such as in a debug situation
func regenerate():
	request_regenerate_world.rpc(1)


## Request that the server regenerate
@rpc("authority", "call_local", "reliable")
func request_regenerate_world() -> void:
	assert(multiplayer.is_server())
	randomize()
	# this call will emit game_ready, which will update the seed text
	var new_random_seed: int = randi()
	initialize_clients.rpc(new_random_seed)

	launch_game.rpc()


## Register that this particular player is ready to start the game
@rpc("any_peer", "call_local", "reliable")
func register_player_ready() -> void:
	# TODO: Move this to connection system.
	assert(multiplayer.is_server())
	num_players_ready += 1
	var total_num_players := ConnectionSystem.get_num_players()

	if num_players_ready >= total_num_players:
		# Start the game now that all players are ready
		_start_game()


## Returns the collective information about storage for the given item.
func get_item_storage_info(type: Types.Item) -> ItemStorageInfo:
	var player_id: int = multiplayer.get_unique_id()
	var storage_info := ItemStorageInfo.new()

	storage_info.starting_quantity = get_starting_item_count(type)
	storage_info.starting_storage_cap = get_starting_storage_cap(type)
	storage_info.current_quantity = get_item_count(player_id, type)
	storage_info.storage_cap = get_storage_cap(player_id, type)

	# We need to split production up into production and consumption.
	storage_info.production = get_item_production(player_id, type)
	storage_info.consumption = get_item_consumption(player_id, type)

	return storage_info


## Return the starting amount of a resource a player should start with.
## Controlled by starting_resources export in model.tscn. If a resource isn't listed in there,
## the default starting amount is 0.
func get_starting_item_count(type: Types.Item) -> float:
	return float(Globals.settings.starting_resources.get(type, 0))


## Return the starting storage cap for a resource.
## If there is no defined starting cap, use the storage limit hard cap.
func get_starting_storage_cap(type: Types.Item) -> float:
	return Globals.settings.get_storage_cap_item(type)


## Returns the number of items possessed by the specified player.
func get_item_count(player_id: int, item: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	return items.counts.get_for(item)


## Returns the net change rate of the item by the specified player.
func get_item_change_rate(player_id: int, item: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	return items.get_item_change_rate(item)


## Returns the production rate of the item by the specified player.
func get_item_production(player_id: int, item: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	return items.production.get_for(item)


## Returns the consumption rate of the item by the specified player.
func get_item_consumption(player_id: int, item: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	return items.consumption.get_for(item)


## Given the item type and amount, add that many items to this player's PlayerState.
func set_item_count(player_id: int, item: Types.Item, new_count: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	items.counts.set_for(item, new_count)


## Given the item type and new production rate, adjust the item production for this player's
## playerstate
func set_item_production(player_id: int, item: Types.Item, new_production: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	items.production.set_for(item, new_production)


## Given the item type and new consumption rate, adjust the item consumption for this player's
## playerstate
func set_item_consumption(player_id: int, item: Types.Item, new_consumption: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	items.consumption.set_for(item, new_consumption)


## Increases the specified item count by the amount specified
func increase_item_count(player_id: int, item: Types.Item, increase_amount: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.items.counts.increase_for(item, increase_amount)


## Increase the item count by as much as you can while not going over the item's storage cap.
## Returns the amount that the item count was actually increased by.
func increase_item_count_apply_cap(player_id: int, item: Types.Item, amount: float) -> float:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.items.increase_item_count_apply_cap(item, amount)


## Increase the specified item consumption rate by the given amount.
func increase_item_consumption(player_id: int, item: Types.Item, increase_amount: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	items.consumption.increase_for(item, increase_amount)


## Increase the specified item production rate by the given amount.
func increase_item_production(player_id: int, item: Types.Item, increase_amount: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	items.production.increase_for(item, increase_amount)


## Sells some amount of the specified item
func sell_item(player_id: int, item: Types.Item, amount: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items

	# We can't sell more than we have.
	var current_amount: float = items.counts.get_for(item)
	var amount_we_actually_sell: float = min(current_amount, amount)

	# Now cause the amounts to change
	set_item_count(player_id, item, current_amount - amount_we_actually_sell)

	# And get PAID!
	var item_resource: ItemResource = Items.get_info(item)
	var money_earned: float = amount_we_actually_sell * item_resource.sell_value
	increase_item_count(player_id, Types.Item.MONEY, money_earned)


## Returns true if the given player_id (default is ourself) has the resources necessary
## to build this building
func can_afford(building_id: String, player_id: int = multiplayer.get_unique_id()) -> bool:
	var building: BuildingResource = Buildings.get_by_id(building_id)
	var costs: Array[ItemCost] = building.item_costs
	for cost: ItemCost in costs:
		var item_type: Types.Item = cost.item_id
		var cost_amount: float = cost.quantity
		if get_item_count(player_id, item_type) < cost_amount:
			return false
	# otherwise we satisfy all the costs, so we are good
	return true


## Pay the item cost of a building when building it.
func deduct_costs(player_id: int, building_id: String) -> void:
	var building: BuildingResource = Buildings.get_by_id(building_id)
	var costs: Array[ItemCost] = building.item_costs
	for cost: ItemCost in costs:
		increase_item_count(player_id, cost.item_id, -1 * cost.quantity)


## Refund the item cost of a building when deleting it.
func refund_costs(player_id: int, building: BuildingEntity) -> void:
	var building_resource: BuildingResource = Buildings.get_by_id(building.building_id)
	var costs: Array[ItemCost] = building_resource.item_costs
	for cost: ItemCost in costs:
		# Calculate the refund amount
		var actual_quantity: float = cost.quantity * building_resource.refund_value

		var heat_component: HeatComponent = building.get_component("HeatComponent")

		if heat_component != null and building_resource.heat_reduces_value:
			var heat_level: float = heat_component.heat
			var heat_capacity: float = heat_component.heat_capacity
			var heat_fraction: float = heat_level / heat_capacity if heat_capacity > 0.0 else 0.0
			actual_quantity *= (1.0 - heat_fraction)

		# Apply the refund
		if Globals.settings.enable_storage_caps_for_building_sales:
			increase_item_count_apply_cap(player_id, cost.item_id, actual_quantity)
		else:
			increase_item_count(player_id, cost.item_id, actual_quantity)


## Returns true if we can build the building indicated at the location specified
func can_build_at_location(building_id: String, player_id: int, grid_position: Vector2i) -> bool:
	if grid_position.x < 0 or grid_position.x >= world_gen_model.num_cols:
		# Out of bounds
		return false

	# Make sure we can build the building somewhere, before continuing
	if not can_afford(building_id, player_id):
		# We can't build this building at all. just return false
		return false

	# Make sure that the space is open
	if get_building_at(player_id, grid_position) != null:
		# The space isn't open. We can't build there.
		return false

	# Make sure that the building fits into this part of the grid
	var building: BuildingResource = Buildings.get_by_id(building_id)

	if building.placement_destination != world_gen_model.get_layer_type(grid_position.y):
		# Can't place this building in this layer
		return false

	return true


## Returns true if this player can delete the building at the given position.
func can_remove_building(player_id: int, grid_position: Vector2i) -> bool:
	if get_building_at(player_id, grid_position) == null:
		# no building to remove
		return false

	return true


## Get the ore at the given x/y coordinates for the given player id.
func get_ore_at(player_id: int, x: int, y: int) -> Types.Ore:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.ores.get_ore(Vector2i(x, y))


## Set the ore at the given x/y coordinates for the given player id.
## Emits the ores_layout_updated signal.
func set_ore_at(player_id: int, x: int, y: int, ore: Types.Ore) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.ores.set_ore(Vector2i(x, y), ore)
	ores_layout_updated.emit()


## Returns the building at the given position
func get_building_at(player_id: int, grid_position: Vector2i) -> BuildingEntity:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.buildings.get_building_at_pos(grid_position)


## Set the building at the given position to the given building type for all players.
func set_building_at(player_id: int, grid_position: Vector2i, building_id: String) -> void:
	assert(multiplayer.is_server())
	var caller_id := multiplayer.get_remote_sender_id()
	print("doing set building for %d" % caller_id)
	if can_build_at_location(building_id, player_id, grid_position):
		var player_state := player_states.get_state(player_id)
		player_state.add_building(grid_position, building_id)


## Remove the building at the given position for all players.
func remove_building_at(player_id: int, tile_position: Vector2i) -> void:
	assert(multiplayer.is_server())
	print("doing remove building for %d" % multiplayer.get_unique_id())
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.remove_building(tile_position)


## Retrieves a list of buildings for the specified player.
func get_buildings(player_id: int) -> Array[BuildingEntity]:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.buildings.get_all()


## Set the storage limit for a given type
func set_storage_cap(player_id: int, item: Types.Item, new_cap: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var items: ItemModel = player_state.items
	items.storage_caps.set_for(item, new_cap)


## Returns the storage limit for a given type if it exists.
func get_storage_cap(player_id: int, item: Types.Item) -> float:
	var player_state = player_states.get_state(player_id)
	# This check is required because player_state is null the first time this function is called
	# in ItemDisplayRow._ready()
	# TODO: fix this being called when player_state isn't intialized
	if player_state:
		var items: ItemModel = player_state.items
		return items.storage_caps.get_for(item)
	else:
		return 0.0


## Get the heat data list for the given player.
func get_heat_data(player_id: int) -> Array[HeatData]:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.building_heat.get_all()


# PRIVATE METHODS


## Used to actually start the game, once all clients are ready
func _start_game():
	assert(multiplayer.is_server())

	# Start the timer on the server and only on the server.
	_update_timer.wait_time = Globals.settings.update_interval
	_update_timer.start()

	# Now initialize the clients
	randomize()
	var new_random_seed: int = randi()
	initialize_clients.rpc(new_random_seed)
	set_starting_item_counts_and_storage_caps()

	# Launch the game!
	launch_game.rpc()


## Set start item counts and storage caps at start of game.
func set_starting_item_counts_and_storage_caps() -> void:
	for player_id in ConnectionSystem.get_player_id_list():
		for type in Globals.settings.starting_resources.keys():
			var amount: float = get_starting_item_count(type)
			set_item_count(player_id, type, amount)
			set_item_production(player_id, type, 0.0)
			set_item_consumption(player_id, type, 0.0)
		for type in Globals.settings.storage_caps.keys():
			var cap: float = get_starting_storage_cap(type)
			set_storage_cap(player_id, type, cap)
		# TODO: fix this hack
		player_states.get_state(player_id).items.publish()


## Reset the item production and consumption numbers for the update loop.
func _reset_production_consumption() -> void:
	for player_id in ConnectionSystem.get_player_id_list():
		for type in Types.Item.values():
			set_item_production(player_id, type, 0.0)
			set_item_consumption(player_id, type, 0.0)


## Fires whenever the update timer is fired. This should only run on the server.
func _on_update_timer_timeout() -> void:
	assert(multiplayer.is_server())
	# TODO: only update systems when it is necessary
	_reset_production_consumption()
	TradeSystem.update()

	for player_id in ConnectionSystem.get_player_id_list():
		var player_state: PlayerState = player_states.get_state(player_id)
		player_state.update_systems()
		player_state.fire_all_changed_signals()
		player_state.publish()

	_broadcast_tick_done.rpc()


@rpc("any_peer", "call_local", "reliable")
func _broadcast_tick_done() -> void:
	tick_done.emit()

class_name GameModel
extends Node
## This class contains accessors to the major state containers and data for
## the complete current state of the game

## Emitted when the game is finished setting up and is ready to start playing
signal game_ready
## Emitted when ores_layout in PlayerStates is updated.
signal ores_layout_updated()
## Emitted when buildings_list in PlayerStates is updated.
signal buildings_updated()

## The random number seed used for this game
var world_seed: int

## The number of players seen as ready. Used to determine when it is okay to start the game
var num_players_ready := 0

@onready var player_states: PlayerStates  = %PlayerStates
@onready var player_spawner := %PlayerSpawner
@onready var game_state := %GameState
@onready var _update_timer := %UpdateTimer

## Take the world seed from the server and initalize it and the world for all players.
@rpc("call_local", "reliable")
func initialize_clients(server_world_seed: int) -> void:
	world_seed = server_world_seed

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


## Return the starting amount of a resource a player should start with.
## Controlled by starting_resources export in model.tscn. If a resource isn't listed in there,
## the default starting amount is 0.
func get_starting_item_count(type: Types.Item) -> float:
	return float(Globals.settings.starting_resources.get(type, 0))


## Returns a dictionary of all of the items posessed by the player
func get_all_item_counts(player_id: int) -> Dictionary[Types.Item, float]:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.items.duplicate()


## Returns the number of items possessed by the specified player.
func get_item_count(player_id: int, type: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.items[type]

## Returns the number of items possessed by the specified player.
func get_item_change_rate(player_id: int, type: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.item_change_rate[type]


## Given the item type and amount, add that many items to this player's PlayerState.
func set_item_count(player_id: int, type: Types.Item, new_count: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.update_item_count(type, new_count)


## Given the item type and amount, adjust the item change rate for this player's playerstate
func set_item_change_rate(player_id: int, type: Types.Item, new_change_rate: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.update_item_change_rate(type, new_change_rate)


## Increases the specified item count by the amount specified
func increase_item_count(player_id: int, type: Types.Item, increase_amount: float) -> void:
	assert(multiplayer.is_server())
	var player_state: PlayerState = player_states.get_state(player_id)
	var item_count := player_state.items[type]
	set_item_count(player_id, type, item_count + increase_amount)


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
		increase_item_count(player_id, cost.item_id, -1*cost.quantity)


## Refund the item cost of a building when deleting it.
func refund_costs(player_id: int, building_id: String) -> void:
	var building: BuildingResource = Buildings.get_by_id(building_id)
	var costs: Array[ItemCost] = building.item_costs
	for cost: ItemCost in costs:
		increase_item_count(player_id, cost.item_id, cost.quantity)


## Returns true if we can build the building indicated at the location specified
func can_build_at_location(building_id:String, position: PlayerGridPosition) -> bool:
	# Make sure we can build the building somewhere, before continuing
	if not can_afford(building_id, position.player_id):
		# We can't build this building at all. just return false
		return false

	# Make sure that the space is open
	if get_building_at(position) != "":
		# The space isn't open. We can't build there.
		return false

	# Make sure that the building fits into this part of the grid
	var building: BuildingResource = Buildings.get_by_id(building_id)

	if (building.placement_destination != WorldGenModel.get_layer_type(position.tile_position.y)):
			# Can't place this building in this layer
			return false

	return true


## Returns true if this player can delete the building at the given position.
func can_remove_building(position: PlayerGridPosition) -> bool:
	if get_building_at(position) == "":
		# no building to remove
		return false

	return true


## Get the ore at the given x/y coordinates for the given player id.
func get_ore_at(player_id: int, x: int, y: int) -> Types.Ore:
	var index := _get_index_into_ores_layout(x, y)
	if index != -1:
		var player_state := player_states.get_state(player_id)
		return player_state.ores_layout[index]
	else:
		print("trying to read ore to factory layer: (%d, %d, %d)" % [player_id, x, y])
		return Types.Ore.ROCK # no ore in factory layer and must return type, so guess it's rock


## Set the ore at the given x/y coordinates for the given player id.
## Emits the ores_layout_updated signal.
func set_ore_at(player_id: int, x: int, y: int, ore: Types.Ore) -> void:
	var index := _get_index_into_ores_layout(x, y)
	if index != -1:
		var player_state := player_states.get_state(player_id)
		player_state.ores_layout[index] = ore
		ores_layout_updated.emit()
	else:
		print("trying to write ore to factory layer: (%d, %d, %d, %s)" % [player_id, x, y, ore])


## Get the building type at the given position.
func get_building_at(pos: PlayerGridPosition) -> String:
	var player_state: PlayerState = player_states.get_state(pos.player_id)
	for placed_building: PlacedBuilding in player_state.buildings_list:
		if placed_building.position == pos.tile_position:
			return placed_building.id
	return ""


## Set the building at the given position to the given building type for all players.
@rpc("any_peer", "call_local", "reliable")
func set_building_at(
	player_id: int, tile_position: Vector2i, building_id: String
) -> void:
	var caller_id := multiplayer.get_remote_sender_id()
	print("doing set building for %d" % caller_id)
	if can_build_at_location(building_id, PlayerGridPosition.new(player_id, tile_position)):
		var player_state := player_states.get_state(player_id)
		player_state.buildings_list.append(PlacedBuilding.new(tile_position, building_id))
		buildings_updated.emit()


## Remove the building at the given position for all players.
@rpc("any_peer", "call_local", "reliable")
func remove_building_at(player_id: int, tile_position: Vector2i) -> void:
	print("doing remove building for %d" % multiplayer.get_unique_id())
	var player_state : PlayerState = player_states.get_state(player_id)
	var index_to_remove := -1
	for i in player_state.buildings_list.size():
		var placed_building : PlacedBuilding = player_state.buildings_list[i]
		if placed_building.position == tile_position:
			index_to_remove = i
			break
	if index_to_remove != -1:
		player_state.buildings_list.remove_at(index_to_remove)
		buildings_updated.emit()


## Retrieves a list of buildings for the specified player
func get_buildings(player_id: int) -> Array[PlacedBuilding]:
	var player_state : PlayerState = player_states.get_state(player_id)
	return player_state.buildings_list


## Should only be called on the server
func _start_game():
	assert(multiplayer.is_server())

	# Start the timer on the server and only on the server.
	_update_timer.start()

	# Now initialize the clients
	randomize()
	var new_random_seed: int = randi()
	initialize_clients.rpc(new_random_seed)
	set_starting_item_counts()

	# Launch the game!
	launch_game.rpc()


# PRIVATE METHODS

func set_starting_item_counts() -> void:
	for player_id in ConnectionSystem.get_player_id_list():
		for type in Globals.settings.starting_resources.keys():
			var amount: float = get_starting_item_count(type)
			set_item_count(player_id, type, amount)
			set_item_change_rate(player_id, type, 0.0)


## Fires whenever the update timer is fired. This should only run on the server.
func _on_update_timer_timeout() -> void:
	assert(multiplayer.is_server())

	# Stores the amount of time that should have passed since the previous wait time
	var update_time : float = _update_timer.wait_time

	var player_list : Array[int] = ConnectionSystem.get_player_id_list()

	for player_id: int in player_list:
		var buildings: Array[PlacedBuilding] = get_buildings(player_id)

		var current_items: Dictionary[Types.Item, float] = get_all_item_counts(player_id)
		var new_items: Dictionary[Types.Item, float] = current_items.duplicate()

		# Initialize our change rate table.
		# TODO: Don't do this here.
		var change_rates: Dictionary[Types.Item, float]
		var total_energy_production: float = 0.0
		var total_energy_consumption: float = 0.0
		for item_type: Types.Item in Types.Item.values():
			change_rates[item_type] = 0.0

		# Do the energy pass to determine building efficiency
		for building: PlacedBuilding in buildings:
			var building_resource: BuildingResource = Buildings.get_by_id(building.id)
			var energy_drain_per_second: float = building_resource.energy_drain

			# Consider doing change rates locally instead of here on the server
			new_items[Types.Item.ENERGY] -= energy_drain_per_second * update_time
			change_rates[Types.Item.ENERGY] -= energy_drain_per_second

			# Process energy production vs. consumption
			if energy_drain_per_second > 0:
				total_energy_consumption += energy_drain_per_second
			elif energy_drain_per_second < 0:
				total_energy_production -= energy_drain_per_second

		# Limit energy by energy storage
		var max_energy: float = Globals.settings.get_storage_limit(Types.Item.ENERGY)
		new_items[Types.Item.ENERGY] = min(max_energy, new_items[Types.Item.ENERGY])

		# Calculate energy effienciency
		var energy_effiency: float = 1.0
		if new_items[Types.Item.ENERGY] <= 0.0:
			# We are out of energy
			new_items[Types.Item.ENERGY] = 0.0
			energy_effiency = min(1.0, total_energy_production / total_energy_consumption)
			print("Out of energy. %f / %f = %f effiency"
				% [total_energy_production, total_energy_consumption, energy_effiency])

		# Now do the mining pass
		for building: PlacedBuilding in buildings:
			var building_resource: BuildingResource = Buildings.get_by_id(building.id)
			if (building_resource is MinerResource):
				var miner_resource: MinerResource = building_resource
				var ore_type: Types.Ore = get_ore_at(player_id, building.position.x, building.position.y)
				var item_type_gained: Types.Item = Ores.get_yield(ore_type)
				var item_change_per_second: float = miner_resource.mining_speed * energy_effiency

				new_items[item_type_gained] += item_change_per_second * update_time
				change_rates[item_type_gained] += item_change_per_second

		# Set the new items in the player state
		for item_type: Types.Item in new_items.keys():
			var max_count: float = Globals.settings.get_storage_limit(item_type)
			new_items[item_type] = min(max_count, new_items[item_type])
			if new_items[item_type] != current_items[item_type]:
				set_item_count(player_id, item_type, new_items[item_type])
			set_item_change_rate(player_id, item_type, change_rates[item_type])


## Translate x/y coordinates from the world into the 1D index ores_layout stores data in.
## (0,7) -> 0, (1,7) -> 1, ..., (9,7) -> 10, (0,8) -> 11, ...
func _get_index_into_ores_layout(x: int, y: int) -> int:
	if WorldGenModel.get_layer_num(y) > 0:
		y -= WorldGenModel.layer_thickness # correct for ores_layout not storing data for factory layer
		return y * WorldGenModel.num_cols + x
	else:
		return -1 # no index for factory layer

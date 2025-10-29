class_name GameModel
extends Node
## This class contains accessors to the major state containers and data for
## the complete current state of the game

## Emitted when the game is finished setting up and is ready to start playing
signal game_ready
## Emitted when ores_layout in PlayerStates is updated.
signal ores_layout_updated
## Emitted when buildings_list in PlayerStates is updated.
signal buildings_updated
## Emitted when heat_data_list in PlayerStates is updated.
signal heat_data_updated


## The random number seed used for this game
var world_seed: int

## The number of players seen as ready. Used to determine when it is okay to start the game
var num_players_ready := 0

@onready var player_states: PlayerStates = %PlayerStates
@onready var player_spawner := %PlayerSpawner
@onready var game_state := %GameState
@onready var _update_timer := %UpdateTimer
@onready var _energy_system := %EnergySystem
@onready var _miner_system: MinerSystem = %MinerSystem
@onready var _storage_system: OreStorageSystem = %StorageSystem
@onready var _heat_system: HeatSystem = %HeatSystem

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


## Return the starting storage cap for a resource.
## If there is no defined starting cap, use the storage limit hard cap.
func get_starting_storage_cap(type: Types.Item) -> float:
	return Globals.settings.get_storage_cap_item(type)


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
		increase_item_count(player_id, cost.item_id, -1 * cost.quantity)


## Refund the item cost of a building when deleting it.
func refund_costs(player_id: int, building_id: String) -> void:
	var building: BuildingResource = Buildings.get_by_id(building_id)
	var costs: Array[ItemCost] = building.item_costs
	for cost: ItemCost in costs:
		increase_item_count(player_id, cost.item_id, cost.quantity)


## Returns true if we can build the building indicated at the location specified
func can_build_at_location(building_id: String, player_id: int, grid_position: Vector2i) -> bool:
	if grid_position.x < 0 or grid_position.x >= WorldGenModel.num_cols:
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

	if building.placement_destination != WorldGenModel.get_layer_type(grid_position.y):
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
	var index := _get_index_into_ores_layout(x, y)
	if index != -1:
		var player_state := player_states.get_state(player_id)
		return player_state.ores_layout[index]
	else:
		print("trying to read ore to factory layer: (%d, %d, %d)" % [player_id, x, y])
		return Types.Ore.ROCK  # no ore in factory layer and must return type, so guess it's rock


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


## Returns the building at the given position
func get_building_at(player_id: int, grid_position: Vector2i) -> BuildingEntity:
	var player_state: PlayerState = player_states.get_state(player_id)
	for building_entity: BuildingEntity in player_state.buildings_list:
		if building_entity.position == grid_position:
			return building_entity
	return null


## Set the building at the given position to the given building type for all players.
@rpc("any_peer", "call_local", "reliable")
func set_building_at(player_id: int, grid_position: Vector2i, building_id: String) -> void:
	var caller_id := multiplayer.get_remote_sender_id()
	print("doing set building for %d" % caller_id)
	if can_build_at_location(building_id, player_id, grid_position):
		var player_state := player_states.get_state(player_id)
		player_state.add_building(grid_position, building_id)
		buildings_updated.emit()


## Remove the building at the given position for all players.
@rpc("any_peer", "call_local", "reliable")
func remove_building_at(player_id: int, tile_position: Vector2i) -> void:
	print("doing remove building for %d" % multiplayer.get_unique_id())
	var player_state: PlayerState = player_states.get_state(player_id)
	var did_remove_building = player_state.remove_building(tile_position)
	if did_remove_building:
		buildings_updated.emit()


## Retrieves a list of buildings for the specified player.
func get_buildings(player_id: int) -> Array[BuildingEntity]:
	var player_state: PlayerState = player_states.get_state(player_id)
	if player_state != null:
		return player_state.buildings_list
	else:
		return []


## Sets the energy satisfaction to the new value.
func set_energy_satisfaction(player_id: int, new_es: float) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.update_energy_satisfaction(new_es)


## Gets energy satisfaction.
func get_energy_satisfaction(player_id: int) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.energy_satisfaction


## Set the storage limit for a given type
func set_storage_cap(player_id: int, type: Types.Item, new_cap: float) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.update_storage_cap(type, new_cap)


## Returns the storage limit for a given type if it exists.
func get_storage_cap(player_id: int, type: Types.Item) -> float:
	var player_state = player_states.get_state(player_id)
	# This check is required because player_state is null the first time this function is called
	# in ItemDisplayRow._ready()
	# TODO: fix this being called when player_state isn't intialized
	if player_state:
		return player_state.storage_caps[type]
	else:
		return 0.0


## Set the heat data for the given player to the data given. Is an RPC.
@rpc("any_peer", "call_local", "reliable")
func add_heat_data_at(
		player_id: int, position: Vector2i, heat: float, heat_capacity: float
	) -> void:
	# start function
	var player_state: PlayerState = player_states.get_state(player_id)
	var heat_data: HeatData = HeatData.new(position, heat, heat_capacity)
	player_state.heat_data_list.append(heat_data)
	heat_data_updated.emit()


## Delete the heat data for the given player at the given position. Is an RPC.
@rpc("any_peer", "call_local", "reliable")
func remove_heat_data_at(player_id: int, position: Vector2i) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)

	var heat_data_list: Array[HeatData] = player_state.heat_data_list
	var index_to_remove: int = heat_data_list.find_custom(
		func(elem): return elem.position == position
	)

	if index_to_remove != -1:
		heat_data_list.remove_at(index_to_remove)
		heat_data_updated.emit()


# TODO: Make this set heat for all cells at once
## Set the heat data heat value at the given position to the given value. Is an RPC.
@rpc("any_peer", "call_local", "reliable")
func set_heat_to(player_id: int, position: Vector2i, new_heat: float) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	for heat_data: HeatData in player_state.heat_data_list:
		if heat_data.position == position:
			heat_data.heat = new_heat
			heat_data_updated.emit()


## Get the heat data list for the given player.
func get_heat_data(player_id: int) -> Array[HeatData]:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.heat_data_list


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
			set_item_change_rate(player_id, type, 0.0)
		for type in Globals.settings.storage_caps.keys():
			var cap: float = get_starting_storage_cap(type)
			set_storage_cap(player_id, type, cap)


## Fires whenever the update timer is fired. This should only run on the server.
func _on_update_timer_timeout() -> void:
	assert(multiplayer.is_server())
	# TODO: only update systems when it is necessary
	_storage_system.update()
	_energy_system.update()
	_heat_system.update()
	_miner_system.update()


## Translate x/y coordinates from the world into the 1D index ores_layout stores data in.
## (0,7) -> 0, (1,7) -> 1, ..., (9,7) -> 10, (0,8) -> 11, ...
func _get_index_into_ores_layout(x: int, y: int) -> int:
	if WorldGenModel.get_layer_num(y) > 0:
		y -= WorldGenModel.layer_thickness  # correct for ores_layout not storing data for factory layer
		return y * WorldGenModel.num_cols + x
	else:
		return -1  # no index for factory layer

class_name GameModel
extends Node
## This class contains accessors to the major state containers and data for
## the complete current state of the game

## Emitted when the game is finished setting up and is ready to start playing
signal game_ready
## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float)
## Emitted when ores_layout in PlayerStates is updated.
signal ores_layout_updated()
## Emitted when buildings_list in PlayerStates is updated.
signal buildings_updated()


var world_seed: int
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


## Returns the number of items possessed by the specified player.
func get_item_count(player_id: int, type: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.items[type]


## Given the item type and amount, add that many items to this player's PlayerState.
## TODO: Should we really allow clients to set things directly? Hmmm.
func set_item_count(player_id: int, type: Types.Item, new_count: float) -> void:
	update_item_count.rpc(type, new_count, player_id)


## Increases the specified item count by the amount specified
func increase_item_count(player_id: int, type: Types.Item, increase_amount: float) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	var item_count := player_state.items[type]
	set_item_count(player_id, type, item_count + increase_amount)


## Given the item type and amount, add that many items to the given player id's PlayerState.
@rpc("any_peer", "call_local", "reliable")
func update_item_count(type: Types.Item, amount: float, player_id: int) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.items[type] = amount
	if player_id == multiplayer.get_unique_id():
		# If this change is for the local system, we need to update subscribers
		item_count_changed.emit(player_id, type, amount)


## Returns true if we have the resources necessary to build this building
func can_build(building: Types.Building) -> bool:
	# We aren't handling this right now, so we can build anything
	# RPG: I'll put this together. Allison should focus on _enter_build_mdoe
	return true

## Returns true if this player can delete the building at the given position.
func can_remove_building() -> bool:
	return true

## Translate x/y coordinates from the world into the 1D index ores_layout stores data in.
## (0,7) -> 0, (1,7) -> 1, ..., (9,7) -> 10, (0,8) -> 11, ...
func _get_index_into_ores_layout(x: int, y: int) -> int:
	if WorldGenModel.get_layer_num(y) > 0:
		y -= WorldGenModel.layer_thickness # correct for ores_layout not storing data for factory layer
		return y * WorldGenModel.num_cols + x
	else:
		return -1 # no index for factory layer


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
func get_building_at(pos: TileMapPosition) -> Types.Building:
	var player_state := player_states.get_state(pos.player_id)
	for placed_building in player_state.buildings_list:
		if placed_building.position == pos.tile_position:
			return placed_building.type
	return Types.Building.NONE


## Set the building at the given position to the given building type for all players.
@rpc("any_peer", "call_local", "reliable")
func set_building_at(
	player_id: int, tile_position: Vector2i, new_building_type: Types.Building
) -> void:
	print("doing set building for %d" % multiplayer.get_unique_id())
	var player_state := player_states.get_state(player_id)
	var building_already_there := false
	# if there is a building already in building list, just change its type
	for placed_building in player_state.buildings_list:
		if placed_building.position == tile_position:
			placed_building.type = new_building_type
			building_already_there = true
	# otherwise, add new building to building list
	if not building_already_there:
		player_state.buildings_list.append(PlacedBuilding.new(tile_position, new_building_type))
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

	# Launch the game!
	launch_game.rpc()


## Fires whenever the update timer is fired. This should only run on the server.
func _on_update_timer_timeout() -> void:
	assert(multiplayer.is_server())
	var update_time : float = _update_timer.wait_time

	var player_list : Array[int] = ConnectionSystem.get_player_id_list()

	for player_id: int in player_list:
		var buildings : Array[PlacedBuilding] = get_buildings(player_id)
		var current_energy : float = get_item_count(player_id, Types.Item.ENERGY)
		var new_energy := current_energy

		for building in buildings:
			var building_resource: BuildingResource = Buildings.get_building_resource(building.type)
			new_energy -= building_resource.energy_drain * update_time

		# Set the new energy in the player state
		if new_energy != current_energy:
			set_item_count(player_id, Types.Item.ENERGY, new_energy)

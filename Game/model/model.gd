class_name GameModel
extends Node
## This class contains accessors to the major state containers and data for
## the complete current state of the game

## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: int)
## Emitted when ores_layout in PlayerStates is updated.
signal ores_layout_updated()
## Emitted when buildings_list in PlayerStates is updated.
signal buildings_updated()

var world_seed: int
var player_ids: Array[int]

## Emitted when ores_layout in PlayerStates is updated.
signal ores_layout_updated()

## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float )

@onready var player_states: PlayerStates  = %PlayerStates
@onready var player_spawner := %PlayerSpawner
@onready var game_state := %GameState
@onready var _update_timer := %UpdateTimer


func start_game() -> void:
	player_states.start_game()
	
	if multiplayer.is_server():
		# Start the timer on the server and only on the server.
		_update_timer.start()


## Initialize world_seed and player_ids for both players
## when it is called in set_up_game rpc in World
func initialize_both_player_variables(server_world_seed: int) -> void:
	world_seed = server_world_seed
	player_ids = ConnectionSystem.get_player_id_list()


## Returns the number of items possessed by the specified player.
func get_item_count(player_id: int, type: Types.Item) -> float:
	var player_state: PlayerState = player_states.get_state(player_id)
	return player_state.items[type]
	

## Given the item type and amount, add that many items to this player's PlayerState.
## TODO: Should we really allow clients to set things directly? Hmmm.
func set_item_count(player_id: int, type: Types.Item, new_count: float) -> void:	
	update_item_count.rpc(type, new_count, player_id)
	item_count_changed.emit(player_id, type, new_count)


## Increases the specified item count by the amount specified
func increase_item_count(player_id: int, type: Types.Item, increase_amount: float) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	var item_count = player_state.items[type]
	set_item_count(player_id, type, item_count + increase_amount)


## Given the item type and amount, add that many items to the given player id's PlayerState.
@rpc("any_peer", "call_local", "reliable")
func update_item_count(type: Types.Item, amount: float, player_id: int) -> void:
	var player_state: PlayerState = player_states.get_state(player_id)
	player_state.items[type] = amount


## Returns true if we have the resources necessary to build this building
func can_build(building: Types.Building) -> bool:
	# We aren't handling this right now, so we can build anything
	# RPG: I'll put this together. Allison should focus on _enter_build_mdoe
	return true

## Returns true if this player can delete the building at the given position.
func can_remove() -> bool:
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
	var index = _get_index_into_ores_layout(x, y)
	if index != -1:
		var player_state = player_states.get_state(player_id)
		return player_state.ores_layout[index]
	else:
		print("trying to read ore to factory layer: (%d, %d, %d)" % [player_id, x, y])
		return Types.Ore.ROCK # no ore in factory layer and must return type, so guess it's rock


## Set the ore at the given x/y coordinates for the given player id.
## Emits the ores_layout_updated signal.
func set_ore_at(player_id: int, x: int, y: int, ore: Types.Ore) -> void:
	var index = _get_index_into_ores_layout(x, y)
	if index != -1:
		var player_state = player_states.get_state(player_id)
		player_state.ores_layout[index] = ore
		ores_layout_updated.emit()
	else:
		print("trying to write ore to factory layer: (%d, %d, %d, %s)" % [player_id, x, y, ore])

## returns the building at a specified location on the map
func get_building_at(pos: TileMapPosition) -> Types.Building:
	var player_state = player_states.get_state(pos.player_id)
	for placed_building in player_state.buildings_list:
		if placed_building.position == pos.tile_position:
			return placed_building.type
	return Types.Building.NONE


@rpc("any_peer", "call_local", "reliable")
func set_building_at(player_id: int, tile_position: Vector2i, new_building_type: Types.Building) -> void:
	print("doing set building for %d" % multiplayer.get_unique_id())
	var player_state = player_states.get_state(player_id)
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


@rpc("any_peer", "call_local", "reliable")
func remove_building_at(player_id: int, tile_position: Vector2i) -> void:
	print("doing remove building for %d" % multiplayer.get_unique_id())
	var player_state = player_states.get_state(player_id)
	var index_to_remove = -1
	for i in player_state.buildings_list.size():
		var placed_building = player_state.buildings_list[i]
		if placed_building.position == tile_position:
			index_to_remove = i
			break
	if index_to_remove != -1:
		player_state.buildings_list.remove_at(index_to_remove)
		buildings_updated.emit()


## Retrieves a list of buildings for the specified player
func get_buildings(player_id: int) -> Array[PlacedBuilding]:
	var player_state = player_states.get_state(player_id)
	return player_state.buildings_list


## Fires whenever the update timer is fired. This should only run on the server.
func _on_update_timer_timeout() -> void:
	assert(multiplayer.is_server())
	
	var player_list : Array[int] = ConnectionSystem.get_player_id_list()
	
	for player_id in player_list:
		var buildings : Array[PlacedBuilding] = get_buildings(player_id)	
		var current_energy : float = get_item_count(player_id, Types.Item.ENERGY)
		var new_energy = current_energy
		
		for building in buildings:
			var building_resource: BuildingResource = Buildings.get_building_resource(building)
			new_energy -= building_resource.energy_drain
		
		# Set the new energy in the player state 
		if new_energy != current_energy:
			set_item_count(player_id, Types.Item.ENERGY, new_energy)

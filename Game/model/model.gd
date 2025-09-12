class_name GameModel extends Node

## This class contains accessors to the major state containers and data for
## the complete current state of the game

@onready var _PlayerStates: PlayerStates  = %PlayerStates
@onready var _PlayerSpawner := %PlayerSpawner
@onready var _GameState := %GameState

var world_seed: int
var player_ids: Array[int]

## Emitted when ores_layout in PlayerStates is updated.
signal ores_layout_updated()

func start_game() -> void:
	_PlayerStates.start_game()

## Initialize world_seed and player_ids for both players, when it is called in set_up_game rpc in World
func initialize_both_player_variables(server_world_seed: int) -> void:
	world_seed = server_world_seed
	player_ids = ConnectionSystem.get_player_id_list()

## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: int )

func get_item_count(player_id: int, type: Types.Item) -> int:
	var player_state: PlayerState = _PlayerStates.get_state(player_id)
	return player_state.items[type]
	
## Given the item type and amount, add that many items to this player's PlayerState.
func set_item_count(player_id: int, type: Types.Item, new_count: float) -> void:
	update_item_count.rpc(type, new_count, player_id)
	item_count_changed.emit(player_id, type, new_count)

## Increases the specified item count by the amount specified
func increase_item_count(player_id: int, type: Types.Item, increase_amount: float) -> void:
	var player_state: PlayerState = _PlayerStates.get_state(player_id)
	var item_count = player_state.items[type]
	set_item_count(player_id, type, item_count + increase_amount)

## Given the item type and amount, add that many items to the given player id's PlayerState.
@rpc("any_peer", "call_local", "reliable")
func update_item_count(type: Types.Item, amount: float, player_id: int) -> void:
	var player_state: PlayerState = _PlayerStates.get_state(player_id)
	player_state.items[type] = amount

## Returns true if we have the resources necessary to build this building
func can_build(building: BuildingResource) -> bool:
	# We aren't handling this right now, so we can build anything
	# RPG: I'll put this together. Allison should focus on _enter_build_mdoe
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
		var player_state = _PlayerStates.get_state(player_id)
		return player_state.ores_layout[index]
	else:
		print("trying to read ore to factory layer: (%d, %d, %d)" % [player_id, x, y])
		return Types.Ore.ROCK # no ore in factory layer and must return type, so guess it's rock

## Set the ore at the given x/y coordinates for the given player id. Emits the ores_layout_updated signal.
func set_ore_at(player_id: int, x: int, y: int, ore: Types.Ore) -> void:
	var index = _get_index_into_ores_layout(x, y)
	if index != -1:
		var player_state = _PlayerStates.get_state(player_id)
		player_state.ores_layout[index] = ore
		ores_layout_updated.emit()
	else:
		print("trying to write ore to factory layer: (%d, %d, %d, %s)" % [player_id, x, y, ore])
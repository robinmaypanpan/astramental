extends Node

## Stores mapping from player id -> instantiated player state
var _player_states_dict: Dictionary[int, PlayerState]

@onready var _PlayerSpawner = %PlayerSpawner

## Given a player id, instantiate a new PlayerState and return it.
func spawn_player_state(player_id: int) -> Node:
	var player_state = PlayerState.new()
	var player = ConnectionSystem.get_player(player_id)
	
	player_state.name = str(player_id)
	player_state.id = player_id
	player_state.index = player.index
	for type in Item.Type.values():
		player_state.items[type] = float(player.index)
	
	_player_states_dict[player_id] = player_state

	return player_state

## Spawn a new player state for the given player id.
func add_state(player_id: int) -> void:
	_PlayerSpawner.spawn(player_id)

## Given the player id, retrieve the corresponding PlayerState.
func get_state(player_id: int = multiplayer.get_unique_id()) -> PlayerState:
	return _player_states_dict[player_id]

## Given the item type and amount, add that many items to this player's PlayerState.
func add_item(type: Item.Type, amount: float) -> void:
	add_item_to.rpc(type, amount, multiplayer.get_unique_id())

## Given the item type and amount, add that many items to the given player id's PlayerState.
@rpc("any_peer", "call_local", "reliable")
func add_item_to(type: Item.Type, amount: float, player_id: int) -> void:
	var player_state := get_state(player_id)
	player_state.items[type] += amount

func _ready() -> void:
	_PlayerSpawner.spawn_function = spawn_player_state

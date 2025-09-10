class_name PlayerStates extends Node

## Stores mapping from player id -> instantiated player state
var _player_states_dict: Dictionary[int, PlayerState]

@onready var _PlayerSpawner = %PlayerSpawner

func start_game() -> void:
	var player_ids = ConnectionSystem.get_player_id_list()

	for player_id in player_ids:
		add_state(player_id)

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
func add_state(player_id: int) -> PlayerState:
	return _PlayerSpawner.spawn(player_id)

## Given the player id, retrieve the corresponding PlayerState.
func get_state(player_id: int = multiplayer.get_unique_id()) -> PlayerState:
	return _player_states_dict[player_id]

func _ready() -> void:
	_PlayerSpawner.spawn_function = spawn_player_state

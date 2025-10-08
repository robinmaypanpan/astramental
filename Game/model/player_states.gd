class_name PlayerStates
extends Node
## Primary container for all player states


## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float)

## When an item change rate changes, this signal fires
signal item_change_rate_changed(player_id: int, type: Types.Item, new_change_rate: float)

## Stores mapping from player id -> instantiated player state
var _player_states_dict: Dictionary[int, PlayerState]

@onready var player_spawner := %PlayerSpawner


func _ready() -> void:
	player_spawner.spawn_function = spawn_player_state


## Generates the states for all the different players
func generate_player_states() -> void:
	var player_ids := ConnectionSystem.get_player_id_list()

	for player_id:int in player_ids:
		add_state(player_id)


## Given a player id, instantiate a new PlayerState and return it.
func spawn_player_state(player_id: int) -> Node:
	var player_state := PlayerState.new()
	var player := ConnectionSystem.get_player(player_id)

	player_state.name = str(player_id)
	player_state.id = player_id
	player_state.index = player.index
	for type in Types.Item.values():
		player_state.items[type] = 0.0
		player_state.item_change_rate[type] = 0.0

	_player_states_dict[player_id] = player_state

	return player_state


## Spawn a new player state for the given player id.
func add_state(player_id: int) -> PlayerState:
	var player_state:PlayerState = player_spawner.spawn(player_id)
	player_state.item_count_changed.connect(on_item_count_changed)
	player_state.item_change_rate_changed.connect(on_item_change_rate_changed)
	return player_state


## Given the player id, retrieve the corresponding PlayerState.
func get_state(player_id: int = multiplayer.get_unique_id()) -> PlayerState:
	return _player_states_dict[player_id]

# PRIVATE METHODS

func on_item_count_changed(player_id: int, type: Types.Item, new_count: float) -> void:
	item_count_changed.emit(player_id, type, new_count)


func on_item_change_rate_changed(player_id: int, type: Types.Item, new_change_rate: float) -> void:
	item_change_rate_changed.emit(player_id, type, new_change_rate)

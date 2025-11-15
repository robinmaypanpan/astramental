class_name PlayerStates
extends Node
## Primary container for all player states

## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float)

## When an item production rate changes, this signal fires
signal item_production_changed(player_id: int, type: Types.Item, new_production_rate: float)

## When an item consumption rate changes, this signal fires
signal item_consumption_changed(player_id: int, type: Types.Item, new_consumption_rate: float)

## When an energy satisfaction level changes, this signal fires
signal energy_satisfaction_changed(player_id: int, new_energy_satisfaction: float)

## Scene of player state object to instantiate when making a new player state.
var player_state_scene: PackedScene = preload("res://Game/model/player_state/player_state.tscn")

## Stores mapping from player id -> instantiated player state
var _player_states_dict: Dictionary[int, PlayerState]

@onready var player_spawner := %PlayerSpawner


func _ready() -> void:
	player_spawner.spawn_function = spawn_player_state


## Generates the states for all the different players
func generate_player_states() -> void:
	var player_ids := ConnectionSystem.get_player_id_list()

	for player_id: int in player_ids:
		add_state(player_id)


## Given a player id, instantiate a new PlayerState and return it.
func spawn_player_state(player_id: int) -> Node:
	var player_state: PlayerState = player_state_scene.instantiate()
	var player := ConnectionSystem.get_player(player_id)

	player_state.name = str(player_id)
	player_state.id = player_id
	player_state.index = player.index

	_player_states_dict[player_id] = player_state

	player_state.item_count_changed.connect(on_item_count_changed)
	player_state.item_production_changed.connect(on_item_production_changed)
	player_state.item_consumption_changed.connect(on_item_consumption_changed)
	player_state.energy_satisfaction_changed.connect(on_energy_satisfaction_changed)

	return player_state


## Spawn a new player state for the given player id.
func add_state(player_id: int) -> void:
	player_spawner.spawn(player_id)


## Given the player id, retrieve the corresponding PlayerState.
func get_state(player_id: int = multiplayer.get_unique_id()) -> PlayerState:
	if _player_states_dict.has(player_id):
		return _player_states_dict[player_id]
	else:
		return null


# PRIVATE METHODS


func on_item_count_changed(player_id: int, type: Types.Item, new_count: float) -> void:
	item_count_changed.emit(player_id, type, new_count)


func on_item_production_changed(
	player_id: int, type: Types.Item, new_production_rate: float
) -> void:
	item_production_changed.emit(player_id, type, new_production_rate)


func on_item_consumption_changed(
	player_id: int, type: Types.Item, new_consumption_rate: float
) -> void:
	item_consumption_changed.emit(player_id, type, new_consumption_rate)


func on_energy_satisfaction_changed(player_id: int, new_energy_satisfaction: float) -> void:
	energy_satisfaction_changed.emit(player_id, new_energy_satisfaction)

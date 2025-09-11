class_name GameModel extends Node

## This class contains accessors to the major state containers and data for
## the complete current state of the game

@onready var _PlayerStates: PlayerStates  = %PlayerStates
@onready var _PlayerSpawner := %PlayerSpawner
@onready var _GameState := %GameState

var world_seed: int
var player_ids: Array[int]
var player_boards: Dictionary[int, Node]


func start_game() -> void:
	player_ids = ConnectionSystem.get_player_id_list()
	_PlayerStates.start_game()
	
## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Item.Type, new_count: int )

func get_item_count(player_id: int, type: Item.Type) -> int:
	var player_state: PlayerState = _PlayerStates.get_state(player_id)
	return player_state.items[type]
	
## Given the item type and amount, add that many items to this player's PlayerState.
func set_item_count(player_id: int, type: Item.Type, new_count: float) -> void:
	update_item_count.rpc(type, new_count, player_id)
	item_count_changed.emit(player_id, type, new_count)

## Increases the specified item count by the amount specified
func increase_item_count(player_id: int, type: Item.Type, increase_amount: float) -> void:
	var player_state: PlayerState = _PlayerStates.get_state(player_id)
	var item_count = player_state.items[type]
	set_item_count(player_id, type, item_count + increase_amount)

## Given the item type and amount, add that many items to the given player id's PlayerState.
@rpc("any_peer", "call_local", "reliable")
func update_item_count(type: Item.Type, amount: float, player_id: int) -> void:
	var player_state: PlayerState = _PlayerStates.get_state(player_id)
	player_state.items[type] = amount

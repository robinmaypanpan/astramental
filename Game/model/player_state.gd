class_name PlayerState extends Node


## When an item quantity is changed, this signal fires
signal item_count_changed(player_id: int, type: Types.Item, new_count: float)

## When an item change rate changes, this signal fires
signal item_change_rate_changed(player_id: int, type: Types.Item, new_change_rate: float)

## The player id, assigned by the multiplayer controller.
@export var id: int

## The player index, which starts at 1 for the server and increases by 1 for each successive player.
@export var index: int

## The amount of each item that this player currently has.
@export var items: Dictionary[Types.Item, float]

## The change rate of each item that this player currently has.
@export var item_change_rate: Dictionary[Types.Item, float]

## Contains the layout of the ores for each player.
## Stored as a 1D array that we index into with Model.get_ore_at and Model.set_ore_at.
@export var ores_layout: Array[Types.Ore]

## Contains a list of the positions of each building for this player.
@export var buildings_list: Array[BuildingEntity]

func _ready() -> void:
	var num_layers := WorldGenModel.get_num_mine_layers()
	var layer_size := WorldGenModel.num_cols * WorldGenModel.layer_thickness
	ores_layout.resize(num_layers * layer_size)


## Expected to be used by the server to set the current rate and propogate the responses downstream
func update_item_change_rate(item: Types.Item, change_rate: float) -> void:
	assert(multiplayer.is_server())
	sync_item_change_rate.rpc(item, change_rate)


## Used by the server to set the item count
func update_item_count(type: Types.Item, amount: float) -> void:
	assert(multiplayer.is_server())
	sync_item_count.rpc(type, amount)


## Given the item type and amount, add that many items to the given player id's PlayerState.
@rpc("any_peer", "call_local", "reliable")
func sync_item_count(type: Types.Item, amount: float) -> void:
	items[type] = amount
	item_count_changed.emit(id, type, amount)


@rpc("any_peer", "call_local", "reliable")
func sync_item_change_rate(type: Types.Item, change_rate: float) -> void:
	item_change_rate[type] = change_rate
	item_change_rate_changed.emit(id, type, change_rate)

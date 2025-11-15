class_name ItemProperty
extends Node
## Node representing an item property like item_counts or storage_caps. Gets are done from the real
## copy, and sets are done to a shadow copy, that replicates to the real copy when the sync()
## method is called. The value_Pdict should be replicated across the server with a
## MultiplayerSynchronizer.

@export var value_dict: Dictionary[Types.Item, float]

var _value_dict_shadow: Dictionary[Types.Item, float]


func get_for(item: Types.Item) -> float:
	return value_dict[item]


func get_shadow_for(item: Types.Item) -> float:
	assert(multiplayer.is_server())
	return _value_dict_shadow[item]


func set_for(item: Types.Item, value: float) -> void:
	assert(multiplayer.is_server())
	_value_dict_shadow[item] = value


func increase_for(item: Types.Item, amount: float) -> void:
	assert(multiplayer.is_server())
	_value_dict_shadow[item] += amount


func sync() -> void:
	value_dict = _value_dict_shadow.duplicate()
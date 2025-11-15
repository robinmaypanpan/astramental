class_name ItemProperty
extends Node
## Node representing an item property like item_counts or storage_caps. Gets are done from the real
## copy, and sets are done to a shadow copy, that replicates to the real copy when the sync()
## method is called. The value_Pdict should be replicated across the server with a
## MultiplayerSynchronizer.

## The real values of the property this tick. Is synced by the MultiplayerSynchronizer.
@export var value_dict: Dictionary[Types.Item, float]

## The shadow values of the property, which are the in-progress calculations for the value this
## tick. Can be synchronized across the network with sync().
var _value_dict_shadow: Dictionary[Types.Item, float]


## Get the real values of this property for the given item.
func get_for(item: Types.Item) -> float:
	return value_dict[item]


## Get the shadow values of this property for the given item. Should only be called by the server.
func get_shadow_for(item: Types.Item) -> float:
	assert(multiplayer.is_server())
	return _value_dict_shadow[item]


## Set the shadow value of this property for the given item. Should only be called by the server.
func set_for(item: Types.Item, value: float) -> void:
	assert(multiplayer.is_server())
	_value_dict_shadow[item] = value


## Increase the shadow value of this property for the given item.
## Should only be called by the server.
func increase_for(item: Types.Item, amount: float) -> void:
	assert(multiplayer.is_server())
	_value_dict_shadow[item] += amount


## Sync across the network by copying from shadow to real. The MultiplayerSynchronizer will sync
## the new value on change.
func sync() -> void:
	value_dict = _value_dict_shadow.duplicate()
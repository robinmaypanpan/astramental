class_name SyncProperty
extends Node

## Whether the new server value differs from the current client value, meaning we need to trigger
## a UI update.
signal changed

## Value reduced to PackedByteArray that can be sent across the network by MultiplayerSynchronizer.
## Clients read this value to get the value they need.
## The server writes to this value to publish properties across the network.
@export var value_server: PackedByteArray

## The most up-to-date version of the value known.
## The server uses this as its working copy of the value as changes are being made to it.
## The client copies the server value down to this to use as its current value.
var value_client: Variant


## Serialize the client value so that it can be transferred across the network.
## Default behavior is to use var_to_bytes(). Can be re-implemented by subclasses.
func serialize(value: Variant) -> PackedByteArray:
	return var_to_bytes(value)


## Deserialize the server value so that it can be turned into a usable client value.
## Default behavior is to use bytes_to_var(). Can be re-implemented by subclasses.
func deserialize(bytes: PackedByteArray) -> Variant:
	return bytes_to_var(bytes)


## Determine if the old client value and new client value are not equal.
## Default behavior is !=. Can be re-implemented by subclasses.
func not_equal(value1: Variant, value2: Variant) -> bool:
	return value1 != value2


## Publish the value to the network by copying the client value to the server value.
func publish() -> void:
	assert(multiplayer.is_server())
	value_server = serialize(value_client)


## Sync the value from the network to the client by copying the server value to the client value.
func sync() -> void:
	assert(not multiplayer.is_server())
	var new_value_client: Variant = deserialize(value_server)
	if not_equal(value_client, new_value_client):
		changed.emit()
		value_client = new_value_client

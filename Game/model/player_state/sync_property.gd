class_name SyncProperty
extends Node

## Value reduced to primitives that can be sent across the network with MultiplayerSynchronizer.
## Clients read this value to get the value they need.
## The server writes to this value to publish properties across the network.
@export var value_server: Variant

## The most up-to-date version of the value known.
## The server uses this as its working copy of the value as changes are being made to it.
## The client copies the server value down to this to use as its current value.
var value_client: Variant

## Serialize the client value so that it can be transferred across the network.
## Default behavior is to copy the value and return that, effectively not changing it.
## Can be re-implemented by subclasses.
func serialize(value: Variant) -> Variant:
    if value is Array or value is Dictionary:
        return value.duplicate()
    else:
        return value


## Deserialize the server value so that it can be turned into a usable client value.
## Default behavior is to copy the value and return that, effectively not changing it.
## Can be re-implemented by subclasses.
func deserialize(value: Variant) -> Variant:
    if value is Array or value is Dictionary:
        return value.duplicate()
    else:
        return value


## Publish the value to the network by copying the client value to the server value.
func publish() -> void:
    assert(multiplayer.is_server())
    value_server = serialize(value_client)


## Sync the value from the network to the client by copying the server value to the client value.
func sync() -> void:
    assert(not multiplayer.is_server())
    value_client = deserialize(value_server)

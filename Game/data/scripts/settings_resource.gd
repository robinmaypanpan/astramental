class_name SettingsResource
extends Resource

## Defines the resources people start the game with.
@export var starting_resources: Dictionary[Types.Item, float]

## Provides base limits to storage for each item
@export var storage_limits: Dictionary[Types.Item, float]

## Returns the storage limit for a given type if it exists.
## If the storage limit does not exist, returns a very large float value
func get_storage_limit(type: Types.Item) -> float:
	if storage_limits.has(type):
		return storage_limits[type]
	else:
		return 1000000000000000000

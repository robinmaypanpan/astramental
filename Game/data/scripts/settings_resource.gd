class_name SettingsResource
extends Resource

## Defines the resources people start the game with.
@export var starting_resources: Dictionary[Types.Item, float]

## Provides base limits to storage for each item
@export var storage_limits: Dictionary[Types.Item, float]

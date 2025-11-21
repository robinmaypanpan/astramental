class_name SettingsResource
extends Resource

## The hard cap for resources in the game.
const STORAGE_LIMIT_HARD_CAP: float = 1_000_000_000

## Defines the resources people start the game with.
@export var starting_resources: Dictionary[Types.Item, float]

## Provides base caps to storage for each item.
@export var storage_caps: Dictionary[Types.Item, float]

## Define the update interval for the game, defined as how many seconds equals 1 tick.
@export_range(0.05, 1) var update_interval: float

## When true, selling buildings will not provide resources beyond storage caps.
@export var enable_storage_caps_for_building_sales: bool = false


## Get the storage limits for all items. Return the storage limit hard cap if storage_caps
## doesn't include that item.
func get_storage_caps() -> Dictionary[Types.Item, float]:
	var new_storage_caps = storage_caps.duplicate()
	for item in Types.Item.values():
		new_storage_caps.get_or_add(item, STORAGE_LIMIT_HARD_CAP)
	return new_storage_caps


## Get the storage limit for the specified item.
func get_storage_cap_item(item: Types.Item) -> float:
	return storage_caps.get(item, STORAGE_LIMIT_HARD_CAP)

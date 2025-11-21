class_name ItemModel
extends Node
## Model for items. Getters read from real copy i.e. last frame's data, and setters set to the
## shadow copy. Values are synced between players by calling sync(), which copies from shadow to
## real copy.

## Item counts for each item.
@onready var counts: ItemProperty = %ItemCounts

## Item production for each item.
@onready var production: ItemProperty = %ItemProduction

## Item consumption for each item.
@onready var consumption: ItemProperty = %ItemConsumption

## Storage caps for each item.
@onready var storage_caps: ItemProperty = %StorageCaps


## Sync all properties of this model across the network.
func sync() -> void:
	counts.sync()
	production.sync()
	consumption.sync()
	storage_caps.sync()


## Increase the item count by as much as you can while not going over the item's storage cap and
## not below 0. Returns the amount that the item count was actually increased by.
func increase_item_count_apply_cap(item: Types.Item, amount: float) -> float:
	assert(multiplayer.is_server())
	var storage_cap: float = storage_caps.get_for(item)
	var current_item_count: float = counts.get_shadow_for(item)
	var new_item_count: float = clampf(current_item_count + amount, 0.0, storage_cap)
	var actual_change: float = new_item_count - current_item_count
	counts.set_for(item, new_item_count)
	return actual_change


## Get the given item's change rate, which is (production - consumption).
func get_item_change_rate(item: Types.Item) -> float:
	return production.get_for(item) - consumption.get_for(item)

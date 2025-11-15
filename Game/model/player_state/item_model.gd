class_name ItemModel
extends Node
## Model for items. Getters read from real copy i.e. last frame's data, and setters set to the
## shadow copy. Values are synced between players by calling sync(), which copies from shadow to
## real copy.

## Item counts for each item.
@onready var item_counts: ItemProperty = %ItemCounts

## Item production for each item.
@onready var item_production: ItemProperty = %ItemProduction

## Item consumption for each item.
@onready var item_consumption: ItemProperty = %ItemConsumption

## Storage caps for each item.
@onready var storage_caps: ItemProperty = %StorageCaps


## Sync all properties of this model across the network.
func sync() -> void:
	item_counts.sync()
	item_production.sync()
	item_consumption.sync()
	storage_caps.sync()


## Increase the item count by as much as you can while not going over the item's storage cap.
## Returns the amount that the item count was actually increased by.
func increase_item_count_apply_cap(item: Types.Item, amount: float) -> float:
	var storage_cap: float = storage_caps.get_for(item)
	var current_item_count: float = item_counts.get_shadow_for(item)
	var capped_amount: float = min(amount, storage_cap - current_item_count)
	item_counts.increase_for(item, capped_amount)
	return capped_amount


## Get the given item's change rate, which is (production - consumption).
func get_item_change_rate(item: Types.Item) -> float:
	return item_production.get_for(item) - item_consumption.get_for(item)

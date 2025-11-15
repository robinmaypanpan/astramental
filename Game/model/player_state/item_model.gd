class_name ItemModel
extends Node
## Model for items. Getters read from real copy i.e. last frame's data, and setters set to the
## shadow copy. Values are synced between players by calling sync(), which copies from shadow to
## real copy.

@onready var item_counts: ItemProperty = %ItemCounts
@onready var item_production: ItemProperty = %ItemProduction
@onready var item_consumption: ItemProperty = %ItemConsumption
@onready var storage_caps: ItemProperty = %StorageCaps


func sync() -> void:
	item_counts.sync()
	item_production.sync()
	item_consumption.sync()
	storage_caps.sync()


func increase_item_count_apply_cap(item: Types.Item, amount: float) -> float:
	var storage_cap: float = storage_caps.get_for(item)
	var current_item_count: float = item_counts.get_shadow_for(item)
	var capped_amount: float = min(amount, storage_cap - current_item_count)
	item_counts.increase_for(item, capped_amount)
	return capped_amount

class_name ItemStorageInfo

## This is the starting quantity
var starting_quantity: float = 0.0

## This is the storage cap at the time of retrieval
var starting_storage_cap: float = 0.0

## Current quantity when this info was retrieved
var current_quantity: float = 0.0

## Current storage cap when this info was retrieved
var storage_cap: float = 0.0

## Current production when this info was retrieved
var production: float = 0.0

## Current consumption when this info was retrieved
var consumption: float = 0.0


## The net change (production - consumption)
func get_net_change() -> float:
	return production - consumption


## Returns a value from 0 to 1 indicating capacity usage
func get_capacity_percentage() -> float:
	if storage_cap == 0:
		return 0.0
	return current_quantity / storage_cap

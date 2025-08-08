class_name BuildingResource extends Resource

## This is the unique id by which we can reference this building
@export var unique_id: int = 0

## User facing name for this building
@export var name: String = ""

## User facing icon to display in purchase shop
@export var shop_icon: Texture2D = null

## The tile that represents this building
@export var factory_tile: Texture2D = null

## The unit per second energy drain caused by this building
@export var energy_drain: float = 0

## The money cost to build this building
@export var money_cost: int = 0

## A list of item costs needed to build this building, if any
@export var item_costs: Array[ItemCost] = []

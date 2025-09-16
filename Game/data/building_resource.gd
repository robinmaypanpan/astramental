class_name BuildingResource
extends Resource

## User facing name for this building
@export var name: String = ""

## User facing icon to display in purchase shop
@export var icon: AtlasTexture = null

## The unit per second energy drain caused by this building
@export var energy_drain: float = 0

## A list of item costs needed to build this building, if any
@export var item_costs: Array[ItemCost] = []

## The coordinates in the building tileset that correspond to the correct building image.
var atlas_coordinates: Vector2i:
	get:
		var icon_region = icon.region
		return icon_region.position / 16

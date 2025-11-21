class_name HeatComponentData
extends BuildingComponentData

## How much heat this building produces per second.
@export var heat_production: float

## How much heat this building passively cools off per second.
## If set to 0, building will not cool off when reaching max heat until removed.
@export var heat_passive_cool_off: float

## How much heat this building can hold before overheating.
## Once a building reaches the heat capacity, it will start cooling off at
## the cool off rate until it reaches 0 again.
@export var heat_capacity: float


func make_component(unique_id: int, building_entity: BuildingEntity) -> HeatComponent:
	return HeatComponent.new(unique_id, self, building_entity)


func serialize() -> Dictionary:
	var serialized_component_data: Dictionary = super.serialize()
	serialized_component_data["heat_production"] = heat_production
	serialized_component_data["heat_passive_cool_off"] = heat_passive_cool_off
	serialized_component_data["heat_capacity"] = heat_capacity
	return serialized_component_data


static func from_serialized(serialized_component_data: Dictionary) -> HeatComponentData:
	var component_data = HeatComponentData.new()
	component_data.heat_production = serialized_component_data["heat_production"]
	component_data.heat_passive_cool_off = serialized_component_data["heat_passive_cool_off"]
	component_data.heat_capacity = serialized_component_data["heat_capacity"]
	return component_data
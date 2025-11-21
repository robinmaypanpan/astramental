class_name EnergyComponentData
extends BuildingComponentData
## Defines energy consumption/production of this building.

## How much energy this building consumes per second. Can be negative to represent production.
@export var energy_drain: float


func make_component(unique_id: int, building_entity: BuildingEntity) -> EnergyComponent:
	return EnergyComponent.new(unique_id, self, building_entity)


func serialize() -> Dictionary:
	var serialized_component_data: Dictionary = super.serialize()
	serialized_component_data["energy_drain"] = energy_drain
	return serialized_component_data


static func from_serialized(serialized_component_data: Dictionary) -> EnergyComponentData:
	var component_data = EnergyComponentData.new()
	component_data.energy_drain = serialized_component_data["energy_drain"]
	return component_data
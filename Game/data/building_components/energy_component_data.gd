class_name EnergyComponentData
extends BuildingComponentData
## Defines energy consumption/production of this building.

## How much energy this building consumes per second. Can be negative to represent production.
@export var energy_drain: float


func make_component(building_entity: BuildingEntity) -> EnergyComponent:
	return EnergyComponent.new(self, building_entity)
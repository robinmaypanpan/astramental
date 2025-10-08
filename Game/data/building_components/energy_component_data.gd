class_name EnergyComponentData
extends BuildingComponentData

## How much energy this building consumes per second. Can be negative.
@export var energy_drain: float

func make_component(building_entity: BuildingEntity) -> EnergyComponent:
    return EnergyComponent.new(self, building_entity)
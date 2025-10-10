class_name EnergyComponent
extends BuildingComponent
## Instantiated component responsible for tracking energy consumption/production.
## In practice, nearly identical to EnergyComponentData but this won't be the case
## in general for other components.

## How much energy this building consumes per second. Can be negative to represent production.
@export var energy_drain: float:
	get:
		return _data.energy_drain


func _init(ecd: EnergyComponentData, be: BuildingEntity) -> void:
	super(ecd, be, Types.BuildingComponent.ENERGY)
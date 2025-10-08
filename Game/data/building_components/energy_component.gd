class_name EnergyComponent
extends BuildingComponent

@export var energy_drain: float:
    get:
        return _data.energy_drain

func _init(ecd: EnergyComponentData, be: BuildingEntity) -> void:
    super(ecd, be)
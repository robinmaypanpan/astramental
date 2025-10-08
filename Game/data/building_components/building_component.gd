class_name BuildingComponent
extends Object

var building_entity: BuildingEntity

var _data: BuildingComponentData


func _init(bcd: BuildingComponentData, be: BuildingEntity) -> void:
    _data = bcd
    building_entity = be
class_name BuildingComponent
extends Object

var building_entity: BuildingEntity

var type: Types.BuildingComponent

var _data: BuildingComponentData


func _init(bcd: BuildingComponentData, be: BuildingEntity, t: Types.BuildingComponent) -> void:
	_data = bcd
	building_entity = be
	type = t

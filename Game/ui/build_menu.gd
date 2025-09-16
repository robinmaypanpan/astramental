class_name BuildMenu extends PanelContainer

signal on_building_clicked(building: Types.Building)

@export var path_to_building_assets: String

var _buildings: Array[Types.Building]

@onready var building_list: ItemList = %BuildingList


func _ready() -> void:
	# Clear list
	building_list.clear()

	for building_type in Types.Building.values():
		if building_type != Types.Building.NONE:
			var index = building_list.add_icon_item(Buildings.get_icon(building_type))
			building_list.set_item_text(index, Buildings.get_building_name(building_type))
			_buildings.push_back(building_type)


func _on_building_list_item_clicked(
	index: int, _at_position: Vector2, _mouse_button_index: int
) -> void:
	var building: Types.Building = _buildings[index]
	on_building_clicked.emit(building)

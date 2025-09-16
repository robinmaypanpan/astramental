class_name BuildMenu extends PanelContainer

signal on_building_clicked(building: String)

@export var path_to_building_assets: String

var _buildings: Array[String]

@onready var building_list: ItemList = %BuildingList


func _ready() -> void:
	# Clear list
	building_list.clear()

	for building in Buildings.get_all_buildings():
		var index := building_list.add_icon_item(building.icon)
		building_list.set_item_text(index, building.name)
		_buildings.push_back(building.id)


func _on_building_list_item_clicked(
	index: int, _at_position: Vector2, _mouse_button_index: int
) -> void:
	var building: String = _buildings[index]
	on_building_clicked.emit(building)

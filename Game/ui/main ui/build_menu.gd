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

	Model.item_count_changed.connect(_on_item_count_changed)


func _on_building_list_item_clicked(
	index: int, _at_position: Vector2, _mouse_button_index: int
) -> void:
	var building: String = _buildings[index]
	on_building_clicked.emit(building)

func _on_item_count_changed(_player_id: int, _type: Types.Item, _new_count: float) -> void:
	_disable_unaffordable_buildings()

func _disable_unaffordable_buildings() -> void:
	for index in range(_buildings.size()):
		var building_id: String = _buildings[index]
		building_list.set_item_disabled(index, not Model.can_build(building_id))

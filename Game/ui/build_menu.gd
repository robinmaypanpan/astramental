extends PanelContainer

@export var path_to_building_assets:String

@onready var _BuildingList:ItemList = %BuildingList

var _buildings:Array[BuildingResource]

signal on_building_clicked(building: BuildingResource)

func _ready() -> void:
	# Clear list
	_BuildingList.clear()
	
	var resource_list_path:String = path_to_building_assets
	var paths := ResourceLoader.list_directory(resource_list_path)
	
	for path in paths:
		var resource_path:String = "%s/%s" % [resource_list_path, path]
		var building:BuildingResource = ResourceLoader.load(resource_path)
		if building != null:
			var index = _BuildingList.add_icon_item(building.icon)
			_BuildingList.set_item_text(index, building.name)
			_buildings.push_back(building)


func _on_building_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	var building:BuildingResource = _buildings[index]
	on_building_clicked.emit(building)

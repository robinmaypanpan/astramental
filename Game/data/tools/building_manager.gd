extends Control

## Dictionary containing the list of buildings
var _building_paths = {}

@onready var _BuildingList := %BuildingList

## Path to the building objects
@export var building_resource_path : String = "res://Game/data/buildings/"

@onready var _UniqueId := %UniqueId
@onready var _BuildingName := %BuildingName
@onready var _StoreIcon := %StoreIcon
@onready var _FactoryTile := %FactoryTile
@onready var _EnergyDrain := %EnergyDrain
@onready var _MoneyCost := %MoneyCost
@onready var _FilenamePopup := %FilenamePopup
@onready var _NewBuildingName := %NewBuildingName

var _currently_selected_building: BuildingResource

func _ready() -> void:
	load_building_resources()


func load_building_resources() -> void:
	_BuildingList.clear()
	var building_paths := ResourceLoader.list_directory(building_resource_path)
	for path in building_paths:
		var building_index = _BuildingList.add_item(path.substr(0, path.length() - 5))
		_building_paths[building_index] = "%s%s" % [building_resource_path, path]


func _on_building_list_item_selected(index: int) -> void:
	var path = _building_paths[index]
	var building:BuildingResource = load(path)
	show_building(_currently_selected_building)
	
	
func show_building(building:BuildingResource):
	_currently_selected_building = building
	
	_UniqueId.text = str(building.unique_id)
	_BuildingName.text = building.name
	_EnergyDrain.text = str(building.energy_drain)
	_MoneyCost.text = str(building.money_cost)
	
	_StoreIcon.texture = building.shop_icon
	_FactoryTile.texture = building.factory_tile
		
func save_edits() -> void:
	var current_index:int = _BuildingList.get_selected_items()[0]
	var path = _building_paths[current_index]
	ResourceSaver.save(_currently_selected_building,  "%s%s" % [building_resource_path, path])		
		
func create_new_building(filename: String) -> void:
	var building: BuildingResource = BuildingResource.new()
	building.unique_id = ResourceUID.create_id()
	ResourceSaver.save(building,  "%s%s.tres" % [building_resource_path, filename])
	show_building(building)


func _on_new_button_pressed() -> void:
	_FilenamePopup.show()


func _on_ok_button_pressed() -> void:
	create_new_building(_NewBuildingName.text)
	_FilenamePopup.hide()


func _on_cancel_filename_pressed() -> void:
	_FilenamePopup.hide()


func _on_new_building_name_text_submitted(new_text: String) -> void:	
	create_new_building(_NewBuildingName.text)
	_FilenamePopup.hide()

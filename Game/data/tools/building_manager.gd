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
var _current_building_path:String
var _dirty_time:int
var _dirty:bool = false

func _ready() -> void:
	load_building_resources()

func _process(delta: float) -> void:
	var current_time = Time.get_ticks_msec()
	if _dirty and current_time - _dirty_time > 2000:
		save_edits()
		

func load_building_resources() -> void:
	_BuildingList.clear()
	var building_paths := ResourceLoader.list_directory(building_resource_path)
	for path in building_paths:
		var building_index = _BuildingList.add_item(path.substr(0, path.length() - 5))
		_building_paths[building_index] = "%s%s" % [building_resource_path, path]


func _on_building_list_item_selected(index: int) -> void:
	if _dirty:
		save_edits()
	
	var path = _building_paths[index]
	var building:BuildingResource = load(path)
	
	_current_building_path = path
	_currently_selected_building = building	
	
	show_building(_currently_selected_building)
	
	
func show_building(building:BuildingResource):
	
	_UniqueId.text = str(building.unique_id)
	_BuildingName.text = building.name
	_EnergyDrain.text = str(building.energy_drain)
	_MoneyCost.text = str(building.money_cost)
	
	_StoreIcon.texture = building.shop_icon
	_FactoryTile.texture = building.factory_tile
		
func save_edits() -> void:	
	_dirty = false
	var current_index:int = _BuildingList.get_selected_items()[0]
	var path = _current_building_path
	print("Saving resource file to %s" % [path])
	var error = ResourceSaver.save(_currently_selected_building,  path)
	if error != OK:
		printerr("Failure! Error Code: %d" %[error])
		
		
func create_new_building(filename: String) -> void:
	var building: BuildingResource = BuildingResource.new()
	building.unique_id = ResourceUID.create_id()
	building.name = filename.to_camel_case()
	var full_path:String = "%s%s.tres" % [building_resource_path, filename]
	var error = ResourceSaver.save(building,  full_path)	
	if error != OK:
		printerr("Failure! Error Code: %d" %[error])
	
	var building_index = _BuildingList.add_item(filename)	
	_building_paths[building_index] = 	full_path
	_current_building_path = full_path
	_currently_selected_building = building
	
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


func _on_unique_id_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		_currently_selected_building.unique_id = new_text.to_int()
		_dirty_time = Time.get_ticks_msec()
		_dirty = true


func _on_building_name_text_changed(new_text: String) -> void:
	_currently_selected_building.name = new_text
	_dirty_time = Time.get_ticks_msec()
	_dirty = true


func _on_energy_drain_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		_currently_selected_building.energy_drain = new_text.to_float()
		_dirty_time = Time.get_ticks_msec()
		_dirty = true


func _on_money_cost_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		_currently_selected_building.energy_drain = new_text.to_int()
		_dirty_time = Time.get_ticks_msec()
		_dirty = true


func _on_dataedit_submitted(new_text: String) -> void:
	save_edits()

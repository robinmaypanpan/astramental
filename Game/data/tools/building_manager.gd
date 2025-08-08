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
	show_building(building)
	
	
func show_building(building:BuildingResource):
	_UniqueId.text = str(building.unique_id)
	_BuildingName.text = building.name
	_EnergyDrain.text = str(building.energy_drain)
	_MoneyCost.text = str(building.money_cost)

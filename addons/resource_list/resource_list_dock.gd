@tool
extends Control

## Dictionary containing the list of resources
var _resource_paths = {}

@onready var _ResourceList: ItemList = %ResourceList
@onready var _LoadButton:MenuButton = %LoadButton

## Path to the building objects
var resource_path : String = "res://Game/data/"
var resource_type: String = "buildings"

func _ready() -> void:
	load_resources()

func load_resources() -> void:
	_ResourceList.clear()
	var base_path = resource_path + resource_type
	var paths := ResourceLoader.list_directory(base_path)
	for path in paths:
		var index = _ResourceList.add_item(path.substr(0, path.length() - 5))
		_resource_paths[index] = "%s/%s" % [base_path, path]


func _on_building_list_item_selected(index: int) -> void:
	var path = _resource_paths[index]
	var resource = load(path)
	EditorInterface.edit_resource(resource)
	

func _on_new_button_pressed() -> void:
	pass # Replace with function body.


func _on_load_buton_about_to_popup() -> void:
	var popup:PopupMenu = _LoadButton.get_popup()
	popup.id_pressed.connect(_on_load_button_popup_pressed)
	
	
func _on_load_button_popup_pressed(id:int) -> void:	
	var popup:PopupMenu = _LoadButton.get_popup()
	popup.id_pressed.disconnect(_on_load_button_popup_pressed)
	var item = popup.get_item_text(id)
	resource_type = item
	load_resources()

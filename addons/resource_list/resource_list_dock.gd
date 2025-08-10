@tool
extends Control

## Dictionary containing the list of resources
var _resource_paths = {}

@onready var _ResourceList: ItemList = %ResourceList
@onready var _LoadButton:MenuButton = %LoadButton
@onready var _NewFilePanel:Control = %NewFilePanel
@onready var _NewFile:LineEdit = %NewFile

## Path to the building objects
var resource_path : String = "res://Game/data/"
var resource_type: String = "buildings"

func _ready() -> void:
	_NewFilePanel.hide()
	load_resources()

func load_resources() -> void:
	_resource_paths.clear()
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
	if _NewFilePanel.visible:
		if _NewFile.text.length() > 0:
			_on_new_file_text_submitted(_NewFile.text)
		_NewFilePanel.hide()
	else:
		_NewFilePanel.show()


func _on_load_buton_about_to_popup() -> void:
	var popup:PopupMenu = _LoadButton.get_popup()
	popup.id_pressed.connect(_on_load_button_popup_pressed)
	
	
func _on_load_button_popup_pressed(id:int) -> void:	
	var popup:PopupMenu = _LoadButton.get_popup()
	popup.id_pressed.disconnect(_on_load_button_popup_pressed)
	var item = popup.get_item_text(id)
	resource_type = item
	load_resources()


func _on_new_file_text_submitted(new_resource_name: String) -> void:
	var first_resource_id = _resource_paths.keys()[0]
	var first_resource = load(_resource_paths[first_resource_id])
	var new_resource = first_resource.duplicate()
	
	var new_resource_path = "%s/%s/%s.tres" % [resource_path, resource_type, new_resource_name]
	ResourceSaver.save(new_resource, new_resource_path)
	var index = _ResourceList.add_item(new_resource_path.substr(0, new_resource_path.length() - 5))
	_resource_paths[index] = new_resource_path	
	EditorInterface.edit_resource(new_resource)
	
	_NewFilePanel.hide()

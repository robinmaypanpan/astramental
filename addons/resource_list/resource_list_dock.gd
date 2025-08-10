@tool
extends Control

@onready var _ResourceList: ItemList = %ResourceList
@onready var _LoadButton:MenuButton = %LoadButton
@onready var _NewFilePanel:Control = %NewFilePanel
@onready var _NewFile:LineEdit = %NewFile

## Dictionary containing the list of resources
var _resource_paths = {}
## Which resource list is loaded
var _current_index = 0
## Stores the data for this resource list
var _resource_lists: Array[ResourceListDatum] = []

func _ready() -> void:
	_NewFilePanel.hide()
	if _resource_lists.size() > 0:
		load_resource_list(0)
	

## Loads the resource list data provided at the indicated location
func load_data(data:ResourceListData) -> void:
	_resource_lists = data.resources_data
	if is_node_ready():
		load_resource_list(0)
	
## Loadds the resource list at the indicated index
func load_resource_list(resource_list_index:int) -> void:
	print("Loading resource list %d" % [resource_list_index])
	_current_index = resource_list_index
	var resource_list_data:ResourceListDatum = _resource_lists[resource_list_index]
	
	_resource_paths.clear()
	_ResourceList.clear()
	
	var resource_list_path:String = resource_list_data.resource_dir_path
	var paths := ResourceLoader.list_directory(resource_list_path)
	
	for path in paths:
		var index = _ResourceList.add_item(path.substr(0, path.length() - 5))
		_resource_paths[index] = "%s/%s" % [resource_list_path, path]


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
	
	# Connect so we know what is clicked
	popup.index_pressed.connect(_on_load_button_popup_pressed)
	
	# Populate the menu with resource lists
	for resource_list:ResourceListDatum in _resource_lists:
		popup.add_item(resource_list.type)
	
	
func _on_load_button_popup_pressed(index:int) -> void:	
	var popup:PopupMenu = _LoadButton.get_popup()
	popup.id_pressed.disconnect(_on_load_button_popup_pressed)
	load_resource_list(index)


func _on_new_file_text_submitted(new_resource_name: String) -> void:
	#var resource_list_data:ResourceListDatum = _resource_lists[resource_list_index]
	#var first_resource_id = _resource_paths.keys()[0]
	#var first_resource = load(_resource_paths[first_resource_id])
	#var new_resource = first_resource.duplicate()
	#
	#var new_resource_path = "%s/%s/%s.tres" % [resource_path, resource_type, new_resource_name]
	#ResourceSaver.save(new_resource, new_resource_path)
	#var index = _ResourceList.add_item(new_resource_path.substr(0, new_resource_path.length() - 5))
	#_resource_paths[index] = new_resource_path	
	#EditorInterface.edit_resource(new_resource)
	
	_NewFilePanel.hide()

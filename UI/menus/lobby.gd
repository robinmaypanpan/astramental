extends Menu

@onready var StatusLabel := %StatusLabel
@onready var PlayerList := %PlayerList

func _ready() -> void:
	#multiplayer.connection_failed.connect(_connection_failure)
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	
	var username:String
	
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	else:
		var desktop_path := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		username = desktop_path[desktop_path.size() - 2]
	
	if multiplayer.is_server():
		PlayerList.add_item(username)
	
func _player_connected(id: int) -> void:
	#post_to_log(str("Player ", id,  " connected"))
	pass
	
	
func _player_disconnected(id:int) -> void:
	#post_to_log(str("Player ", id,  " disconnected"))
	pass


func _on_start_button_pressed() -> void:
	UiUtils.transition_to("world");

extends Node

static var player_name : String

func _ready() -> void:
	if OS.has_environment("USERNAME"):
		player_name = OS.get_environment("USERNAME")
	else:
		var desktop_path := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		player_name = desktop_path[desktop_path.size() - 2]

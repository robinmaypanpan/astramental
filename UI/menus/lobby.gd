extends Menu

func _ready() -> void:
	#multiplayer.connection_failed.connect(_connection_failure)
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	
func _player_connected(id: int) -> void:
	#post_to_log(str("Player ", id,  " connected"))
	pass
	
	
func _player_disconnected(id:int) -> void:
	#post_to_log(str("Player ", id,  " disconnected"))
	pass

extends Menu

@onready var StatusLabel := %StatusLabel
@onready var PlayerList := %PlayerList
@onready var StartButton := %StartButton

func _ready() -> void:	
	StartButton.disabled = not multiplayer.is_server()
	
	refresh_lobby()
	ConnectionSystem.player_list_changed.connect(refresh_lobby)
	ConnectionSystem.game_started.connect(_on_game_started)

func refresh_lobby() -> void:
	print("Refresh Lobby")
	PlayerList.clear()
	
	var player_list = ConnectionSystem.get_player_id_list()
	
	for player_id in player_list:
		var player = ConnectionSystem.get_player(player_id)
		var player_name = player.name
		if player_id == multiplayer.get_unique_id():
			player_name += " (you)"
		PlayerList.add_item("%d: %s" % [player.index, player_name])

func _connection_failure() -> void:
	multiplayer.set_multiplayer_peer(null)
	UiUtils.transition_to("MainMenu")


func _on_start_button_pressed() -> void:
	ConnectionSystem.start_game()

func _on_game_started() -> void:	
	UiUtils.transition_to("world");

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
	var players = ConnectionSystem.players
	players.sort()
	PlayerList.clear()
	PlayerList.add_item(Globals.player_name + " (you)")
	for p: String in players.values():
		PlayerList.add_item(p)
		

func _connection_failure() -> void:
	multiplayer.set_multiplayer_peer(null)
	UiUtils.transition_to("MainMenu")


func _on_start_button_pressed() -> void:
	ConnectionSystem.start_game()

func _on_game_started() -> void:	
	UiUtils.transition_to("world");

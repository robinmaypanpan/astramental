# This is the control script for the server scene, which handles loading the
# server and coordinating 
class_name MainMenu extends Menu

@onready var LogBox : RichTextLabel = $%EventLog
@onready var IPText : LineEdit = %IPInput
@onready var JoinButton : Button = %JoinButton
@onready var PlayerName : LineEdit = %PlayerName

func post_to_log(msg: String) -> void:
	print(msg)
	LogBox.add_text(str(msg) + "\n")
	
	
func _ready() -> void:
	ConnectionSystem.connection_message.connect(post_to_log)
	ConnectionSystem.connection_failed.connect(_on_connection_failed)
	ConnectionSystem.connection_succeeded.connect(_on_connection_succeeded)
	
	if visible: 
		initialize_focus()
		
	PlayerName.placeholder_text = ConnectionSystem.get_predicted_local_player_name()
	
	
func _on_connection_failed() -> void:
	post_to_log("[color=red]Connection Failed[/color]")
	UiUtils.transition_to("MainMenu")
	
	
func _on_host_button_pressed() -> void:
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Server"
	ConnectionSystem.host_server(PlayerName.text)


func _on_join_button_pressed() -> void:
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Client"
	var host_ip: String = "127.0.0.1" if IPText.text.length() == 0 else IPText.text
	ConnectionSystem.join_server(PlayerName.text, host_ip)


func _on_connection_succeeded() -> void:
	UiUtils.transition_to("Lobby")
	

func _on_options_button_pressed() -> void:
	post_to_log("Not yet implemented")


func _on_exit_button_pressed() -> void:
	ConnectionSystem.shutdown_server()
	get_tree().quit()


func initialize_focus() -> void:
	if is_node_ready():
		JoinButton.grab_focus()
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		ConnectionSystem.shutdown_server()
		get_tree().quit() # default behavior


func _on_visibility_changed() -> void:
	if visible:
		initialize_focus()


func _on_ip_input_focus_entered() -> void:
	IPText.edit()


func _on_ip_input_text_submitted(new_text: String) -> void:
	# Do the same thing as clicking the join button
	_on_join_button_pressed()


func _on_player_name_focus_entered() -> void:
	PlayerName.edit()

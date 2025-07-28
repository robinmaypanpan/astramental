# This is the control script for the server scene, which handles loading the
# server and coordinating 
extends Control

@onready var LogBox : RichTextLabel = $%EventLog
@onready var IPText : LineEdit = $%IPInput
@onready var JoinButton : Button = %JoinButton

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of May 2024:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 23458
const MAX_PEERS = 4

var peer : ENetMultiplayerPeer

# This enum lists all the possible states the character can be in.
enum States {IDLE, CONNECTING, CONNECTED, DISCONNECTING}

# This variable keeps track of the character's current state.
var connection_state: States = States.IDLE


func post_to_log(msg: String) -> void:
	print(msg)
	LogBox.add_text(str(msg) + "\n")
	
	
func _ready() -> void:
	multiplayer.connection_failed.connect(_connection_failure)
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	if visible: 
		initialize_focus()
	
	
func _connection_failure() -> void:
	post_to_log("[color=red]Connection Failed[/color]")
	shutdown_server()
	
	
func start_server() -> void:
	connection_state = States.CONNECTING
	post_to_log("Starting Server on port " + str(DEFAULT_PORT) + "...")
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)
	connection_state = States.CONNECTED
	post_to_log("Server Started...")
	
	
func shutdown_server() -> void:
	connection_state = States.DISCONNECTING
	post_to_log("Shutting down...")
	# TODO: What else do I need to do to shut down the server?
	multiplayer.set_multiplayer_peer(null) # Remove peer
	peer = null
	#_connect_btn.set_pressed_no_signal(false)
	connection_state = States.IDLE
	
	
func _player_connected(id: int) -> void:
	post_to_log(str("Player ", id,  " connected"))
	pass
	
	
func _player_disconnected(id:int) -> void:
	post_to_log(str("Player ", id,  " disconnected"))
	pass


func _on_host_button_pressed() -> void:
	start_server()


func _on_join_button_pressed() -> void:
	post_to_log("Connecting to " + IPText.text + ":" + str(DEFAULT_PORT))
	post_to_log("Not yet implemented")


func _on_options_button_pressed() -> void:
	post_to_log("Not yet implemented")


func _on_exit_button_pressed() -> void:
	shutdown_server()
	get_tree().quit()


func initialize_focus() -> void:
	if is_node_ready():
		JoinButton.grab_focus()
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown_server()
		get_tree().quit() # default behavior


func _on_visibility_changed() -> void:
	if visible:
		initialize_focus()


func _on_ip_input_focus_entered() -> void:
	IPText.edit()
	pass

func _on_ip_input_text_submitted(new_text: String) -> void:
	# Do the same thing as clicking the join button
	_on_join_button_pressed()

# This is the control script for the server scene, which handles loading the
# server and coordinating 
extends Control

#@onready var _log_box: RichTextLabel = $Panel/VBoxContainer/Panel/LogResults
#@onready var _connect_btn: CheckButton = $Panel/VBoxContainer/HBoxContainer/Connect

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
	#_log_box.add_text(str(msg) + "\n")
	
func _ready() -> void:
	multiplayer.connection_failed.connect(_connection_failure)
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	
func _on_connect_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if connection_state == States.IDLE:
			start_server()
		#else: 
			#_connect_btn.set_pressed_no_signal(false)
	else:
		if connection_state == States.CONNECTED:
			shutdown_server()
		#else:
			#_connect_btn.set_pressed_no_signal(true)
	
func _connection_failure() -> void:
	post_to_log("[color=red]Connection Failed[/color]")
	shutdown_server()
	
func start_server() -> void:
	connection_state = States.CONNECTING
	post_to_log("Starting Server...")
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)
	connection_state = States.CONNECTED
	#_connect_btn.set_pressed_no_signal(true)
	
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

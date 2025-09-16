extends Node

signal connection_failed
signal connection_succeeded
signal player_list_changed
signal connection_message(message: String)
signal game_started

# This enum lists all the possible states the character can be in.
enum States { IDLE, CONNECTING, CONNECTED, DISCONNECTING }

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of May 2024:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 23458
const MAX_PEERS = 4

var peer: ENetMultiplayerPeer

# This variable keeps track of the connection's current state.
var connection_state: States = States.IDLE

## Stores the list of players
var _players := Dictionary()

## Caches the list of player ids
var _player_ids: Array[int] = []

var _predicted_local_player_name: String


func _ready() -> void:
	multiplayer.connection_failed.connect(_connection_failure)
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)

	if OS.has_environment("USERNAME"):
		_predicted_local_player_name = OS.get_environment("USERNAME")
	else:
		var desktop_path := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		_predicted_local_player_name = desktop_path[desktop_path.size() - 2]

	_generate_player_id_list()

	print("Connection System is ready")


## Returns the predicted local player name
func get_predicted_local_player_name() -> String:
	return _predicted_local_player_name


## Returns true if we are not connected
func is_not_running_network() -> bool:
	return connection_state == States.IDLE


## Start the game on all clients
func start_game() -> void:
	print("Starting all games")
	# Do this one last time before we get started
	_generate_player_id_list()
	assert(multiplayer.is_server())
	_start_all_games.rpc()


## Starts the server on this system
func host_server(local_player_name: String = "") -> void:
	if connection_state != States.IDLE:
		connection_message.emit("Unable to join, connection already active")
		return
	connection_state = States.CONNECTING
	connection_message.emit("Starting Server on port " + str(DEFAULT_PORT) + "...")

	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)

	if local_player_name.length() == 0:
		local_player_name = _predicted_local_player_name

	register_player(1, local_player_name, 1)

	connection_state = States.CONNECTED
	connection_message.emit("Server Started...")
	connection_succeeded.emit()


## Sets this instance of the game as a client and tries to connect to the
## provided server
func join_server(local_player_name: String, ip_address: String) -> void:
	if connection_state != States.IDLE:
		connection_message.emit("Unable to join, connection already active")
		return
	connection_state = States.CONNECTING
	connection_message.emit("Connecting to " + ip_address + ":" + str(DEFAULT_PORT))

	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)

	await multiplayer.connected_to_server

	if local_player_name == null or local_player_name.length() == 0:
		local_player_name = _predicted_local_player_name

	_request_join_game.rpc_id(1, local_player_name)

	connection_state = States.CONNECTED
	connection_succeeded.emit()


## Shuts down the server or the connection to the server
func shutdown_server() -> void:
	connection_state = States.DISCONNECTING
	connection_message.emit("Shutting down...")
	# TODO: What else do I need to do to shut down the server?
	multiplayer.set_multiplayer_peer(null)  # Remove peer
	peer = null
	connection_state = States.IDLE


## Register a player in the local list of players
func register_player(player_id: int, player_name: String, player_index: int):
	var new_player := NetworkPlayer.new()
	new_player.name = player_name
	new_player.index = player_index

	_players[player_id] = new_player

	_generate_player_id_list()
	player_list_changed.emit()


## remove a player from the local list of players
func unregister_player(player_id: int):
	if _players.has(player_id):
		_players.erase(player_id)
		_generate_player_id_list()
		player_list_changed.emit()


## Returns the number of connected players, including the local player
func get_num_players() -> int:
	return _players.size()


## Returns an array of player ids, sorted by index
func get_player_id_list() -> Array[int]:
	return _player_ids
	
## Rebuilds the list of player ids
func _generate_player_id_list() -> void:
	if connection_state == States.IDLE or _players.size() == 0:
		_player_ids = []

	var player_indices := {}

	for player_id in _players.keys():
		var player: NetworkPlayer = _players[player_id]
		player_indices[player.index] = player_id

	_player_ids = []
	for idx:int in range(_players.size()):
		_player_ids.append(player_indices[idx + 1])


## Returns a NetworkPlayer struct for a given player id
func get_player(player_id: int) -> NetworkPlayer:
	return _players[player_id]


func _connection_failure() -> void:
	multiplayer.set_multiplayer_peer(null)
	shutdown_server()


func _player_connected(id: int) -> void:
	print("Player " + str(id) + " connected. Awaiting join request")


## Handles a player joining the game after connecting
@rpc("call_remote", "any_peer", "reliable")
func _request_join_game(player_name: String):
	# TODO SANITIZE THAT PLAYER NAME OMG
	assert(multiplayer.is_server())
	# TODO: Handle reconnection case and mid-game connection
	var new_player_id := multiplayer.get_remote_sender_id()
	var new_player_index := _players.size() + 1

	print(
		(
			"Received join request from player %d, named %s. Assigning index %d"
			% [new_player_id, player_name, new_player_index]
		)
	)

	# First introduce the new player to all existing players
	var old_player_string := ""
	for player_id in _players.keys():
		var player = _players[player_id]
		old_player_string += "%d:%d:%s;" % [player_id, player.index, player.name]
	_introduce_old_players.rpc_id(new_player_id, old_player_string)

	# Next introduce all players to the new player, including the new player
	register_player(new_player_id, player_name, new_player_index)
	_introduce_new_player.rpc(new_player_id, player_name, new_player_index)


## Introduces a newly joined players to all players that have come before
@rpc("authority", "call_remote", "reliable")
func _introduce_old_players(old_player_string: String):
	print("Adding existing players to player list")
	var old_players := old_player_string.split(";")
	for player_string in old_players:
		if player_string.length() == 0:
			continue
		var player_data := player_string.split(":")
		register_player(int(player_data[0]), player_data[2], int(player_data[1]))


## Introduces a player to a newly joined player
@rpc("authority", "call_remote", "reliable")
func _introduce_new_player(player_id, player_name, new_player_index):
	print("Adding new player %s to player list" % [player_name])
	register_player(player_id, player_name, new_player_index)


## Called when a player disconnects
func _player_disconnected(id: int) -> void:
	print(str("Player ", id, " disconnected"))
	unregister_player(id)


@rpc("call_local", "reliable")
func _start_all_games() -> void:
	game_started.emit()


## Stores data about a given player
class NetworkPlayer:
	## Player index, such as "Player 1" or "Player 2" Starts at 1
	var index: int
	## Stores the name of the player
	var name: String

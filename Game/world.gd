extends Control

@export var PlayerBoard : PackedScene

var all_players : Dictionary

func spawn_player_board(data: Variant) -> Node:
	var board := PlayerBoard.instantiate()
	board.OwnerId = data["id"]
	board.OwnerName = data["name"]
	board.WorldSeed = data["world_seed"]
	return board

func generate_boards() -> void:
	print("starting generation, all_players is %s" % all_players)
	for player_id in all_players:
		var player_name = all_players[player_id]
		%Spawner.spawn({
			"id": player_id,
			"name": player_name,
			"world_seed": randi(),
		})


func _ready() -> void:
	print(
		"%s (%s) says the players are %s" % [
			multiplayer.get_unique_id(),
			Globals.player_name,
			ConnectionSystem.players,
	])
	%Spawner.spawn_function = spawn_player_board
	if multiplayer.is_server():
		all_players = ConnectionSystem.players.duplicate()
		all_players[multiplayer.get_unique_id()] = Globals.player_name
		generate_boards()

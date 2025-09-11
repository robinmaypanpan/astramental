class_name Asteroid extends Control

@onready var _BoardHolder := %BoardHolder

@export var Model: GameModel
@export var PlayerBoard : PackedScene
@export var MineLayer : PackedScene

# game board properties
@export var num_cols: int = 10
@export var layer_thickness: int = 7
@export var sky_height: int = 300
@export var tile_map_scale: int = 2

func get_player_boards() -> Array[Node]:
	return _BoardHolder.get_children()
	
## Given a player id, instantiate and add a board whose owner is the given player.
func add_player_board(player_id: int) -> void:
	var board = PlayerBoard.instantiate()

	board.owner_id = player_id
	board.NumCols = num_cols
	board.LayerThickness = layer_thickness
	board.SkyHeight = sky_height
	board.TileMapScale = tile_map_scale

	_BoardHolder.add_child(board)
	Model.player_boards[player_id] = board

## Set up the dictionary to associate an empty array to each player id in the game.
func _init_ores_for_each_player() -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in Model.player_ids:
		ores_for_each_player[player_id] = []
	return ores_for_each_player

## Generate the mine layers for all players by instantiating and adding individual mine layer scenes to each player board.
func generate_all_ores() -> void:
	seed(Model.world_seed)

	for layer_num in range(Ores.get_num_mine_layers()):
		var layer_gen_data := Ores.get_layer_generation_data(layer_num)
		var background_rock := layer_gen_data.background_rock
		var ores_for_each_player := _init_ores_for_each_player()
		var players_not_chosen_yet := Model.player_ids.duplicate()

		# for each ore generation data in this layer
		for ore_gen_data in layer_gen_data.ores:
			if ore_gen_data.generate_for_all_players:
				# if it's for all players, add it for all players
				for player_id in Model.player_ids:
					ores_for_each_player[player_id].append(ore_gen_data)
			else:
				# otherwise, assign it to a player that hasn't gotten a random ore yet
				players_not_chosen_yet.shuffle()
				var random_player: int = players_not_chosen_yet.pop_back()
				ores_for_each_player[random_player].append(ore_gen_data)
				# if we've assigned a random ore to each player at least once, do it again
				if players_not_chosen_yet.size() == 0:
					players_not_chosen_yet = Model.player_ids.duplicate()
		
		# actually generate and add the ore boards to each player
		for player_id in Model.player_ids:
			var mine_layer = MineLayer.instantiate()
			mine_layer.num_rows = layer_thickness
			mine_layer.num_cols = num_cols
			mine_layer.tile_map_scale = tile_map_scale
			Model.player_boards[player_id].add_mine_layer(mine_layer)

			var player_ore_gen_data := ores_for_each_player[player_id]
			mine_layer.generate_ores(background_rock, player_ore_gen_data)

func generate_player_boards() -> void:
	for player_id in Model.player_ids:
		add_player_board(player_id)

	generate_all_ores()

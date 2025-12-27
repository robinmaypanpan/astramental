extends Node
## Contains the logic for generating the world

## Defines a circle filled with the specified ore.
class OreCircle:
	var ore: Types.Ore
	var center: Vector2
	var radius: float

	func _init(o, c, r) -> void:
		ore = o
		center = c
		radius = r


# game board properties
@export var num_cols: int = 10
@export var layer_thickness: int = 7
@export var sky_height: int = 300
@export var tile_map_scale: int = 2
## Resource generation information stored as an array.
## Index 0 corresponds to 1st mine layer, index 1 is 2nd mine layer, and so on.
@export var ores_generation: Array[LayerGenerationResource]


## Given the layer number, return the resource generation information for
## that layer. Layer 0 is the factory/topmost layer, layer 1 is the 1st mine
## layer, and so on.
func get_layer_generation_data(layer_num: int) -> LayerGenerationResource:
	if layer_num > 0:
		return ores_generation[layer_num - 1]
	else:
		return null


## Return the number of layers that are being generated for the mines.
func get_num_mine_layers() -> int:
	return ores_generation.size()


## Return the total number of layers being generated, which is 1 factory layer + all mine layers.
func get_total_num_layers() -> int:
	return get_num_mine_layers() + 1


## Get the y-level where the mine layers start.
func get_mine_layer_start_y() -> int:
	return layer_thickness


## Get the y-level where all layers end. For use in range(), this y-level
## is 1 beyond the bounds of the actual array.
func get_all_layers_end_y() -> int:
	return layer_thickness * get_total_num_layers()


## Get the layer number associated with the y-coordinate. Index 0 is
## top/factory layer, index 1 is 1st mine layer, etc.
func get_layer_num(y: int) -> int:
	@warning_ignore("integer_division") return y / layer_thickness


## Get the layer type (mine layer or factory layer) associated with the
## y-coordinate.
func get_layer_type(y: int) -> Types.Layer:
	if get_layer_num(y) > 0:
		return Types.Layer.MINE
	else:
		return Types.Layer.FACTORY


## Generate the mine layers for all players by instantiating and adding
## individual mine layer scenes to each player board.
func generate_all_ores() -> void:
	seed(Model.world_seed)

	# layer 0 is factory layer. layer 1 is 1st mine layer
	for layer_num in range(1, get_num_mine_layers() + 1):
		var layer_gen_data: LayerGenerationResource = get_layer_generation_data(layer_num)
		var background_rock := layer_gen_data.background_rock
		var ores_for_each_player := _init_ores_for_each_player()
		var players_not_chosen_yet: Array[int] = ConnectionSystem.get_player_id_list().duplicate()

		# for each ore generation data in this layer
		for ore_gen_data in layer_gen_data.ores:
			if ore_gen_data.generate_for_all_players:
				# if it's for all players, add it for all players
				for player_id in ConnectionSystem.get_player_id_list():
					ores_for_each_player[player_id].append(ore_gen_data)
			else:
				# otherwise, assign it to a player that hasn't gotten a random ore yet
				players_not_chosen_yet.shuffle()
				var random_player: int = players_not_chosen_yet.pop_back()
				ores_for_each_player[random_player].append(ore_gen_data)
				# if we've assigned a random ore to each player at least once, do it again
				if players_not_chosen_yet.size() == 0:
					players_not_chosen_yet = ConnectionSystem.get_player_id_list().duplicate()

		# actually fill in the ore for each player
		for player_id in ConnectionSystem.get_player_id_list():
			var player_ore_gen_data := ores_for_each_player[player_id]
			var player_state: PlayerState = Model.player_states.get_state(player_id)
			generate_layer_ores(player_state, background_rock, player_ore_gen_data, layer_num)


## Given ore generation data, generate the ores for the given layer number by filling
## out the tile map layer with the appropriate ores.
func generate_layer_ores(
	player_state: PlayerState, background_rock: Types.Ore, generation_data: Array, layer_num: int
) -> void:
	# TODO: RPG: This should be in the model, not the UI
	# first, make a random circle for each ore
	var ore_circles: Array[OreCircle]

	var layer_start_y := layer_num * layer_thickness
	var layer_end_y := layer_start_y + layer_thickness
	for ore_gen_data: OreGenerationResource in generation_data:
		var ore := ore_gen_data.ore
		var radius := ore_gen_data.size

		var random_center := Vector2(
			randf_range(0, WorldGenModel.num_cols),
			randf_range(layer_start_y, layer_end_y),
		)
		var random_radius := randfn(radius, 0.3)
		ore_circles.append(OreCircle.new(ore, random_center, random_radius))

	var ores = player_state.ores
	# then, for each tile in the tilemap
	for x in range(WorldGenModel.num_cols):
		for y in range(layer_start_y, layer_end_y):
			var center_of_tile := Vector2(x + 0.5, y + 0.5)
			# if no ore is found, write the background rock
			var closest_ore := background_rock
			var closest_distance := 9999.0

			# find the ore circle that is closest to the tile that is within the radius of the ore circle
			for ore_circle in ore_circles:
				var dist_to_center := center_of_tile.distance_to(ore_circle.center)
				if dist_to_center < ore_circle.radius and dist_to_center < closest_distance:
					closest_ore = ore_circle.ore
					closest_distance = dist_to_center

			# set the tile to whatever we did or didn't find
			ores.set_ore(Vector2i(x, y), closest_ore)


## Set up the dictionary to associate an empty array to each player id in the game.
func _init_ores_for_each_player() -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in ConnectionSystem.get_player_id_list():
		ores_for_each_player[player_id] = []
	return ores_for_each_player

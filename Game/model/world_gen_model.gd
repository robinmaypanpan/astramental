class_name WorldGenModel
extends Node
## Contains the logic for generating the world

# Number of columns in a player board.
@export var num_cols: int = 10

# Number of rows in each layer of player board.
@export var num_rows_layer: int = 7

## Resource generation information stored as an array.
## Index 0 corresponds to 1st mine layer, index 1 is 2nd mine layer, and so on.
@export var ores_generation: Array[LayerGenerationResource]

## The random number seed used for this game.
var world_seed: int

# Number of mine layers in player board.
var num_mine_layers: int

# Total number of layers (factory + mine) in player board.
var num_layers: int

# Total number of rows in player board.
var num_rows: int

func _ready() -> void:
	# Set up internal variables.
	num_mine_layers = ores_generation.size()
	num_layers = 1 + num_mine_layers
	num_rows = num_rows_layer * num_layers


## Given the layer number, return the resource generation information for
## that layer. Layer 0 is the factory/topmost layer, layer 1 is the 1st mine
## layer, and so on.
func get_layer_generation_data(layer_num: int) -> LayerGenerationResource:
	if layer_num > 0:
		return ores_generation[layer_num - 1]
	else:
		return null


## Get the y-level where the mine layers start.
func get_mine_layer_start_y() -> int:
	return num_rows_layer


## Get the y-level where all layers end. For use in range(), this y-level
## is 1 beyond the bounds of the actual array.
func get_all_layers_end_y() -> int:
	return num_rows_layer * num_layers


## Get the layer number associated with the y-coordinate. Index 0 is
## top/factory layer, index 1 is 1st mine layer, etc.
func get_layer_num(y: int) -> int:
	@warning_ignore("integer_division") return y / num_rows_layer


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
	seed(world_seed)

	# layer 0 is factory layer. layer 1 is 1st mine layer
	for layer_num in range(1, num_layers):
		var layer_gen_data: LayerGenerationResource = get_layer_generation_data(layer_num)
		var background_rock: Types.Ore = layer_gen_data.background_rock
		var ores_for_each_player: Dictionary[int, Array] = _init_ores_for_each_player()
		var players_not_chosen_yet: Array[int] = ConnectionSystem.get_player_id_list().duplicate()

		# for each ore generation data in this layer
		for ore_gen_data: OreGenerationResource in layer_gen_data.ores:
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
			var player_ore_gen_data: Array = ores_for_each_player[player_id]
			var player_state: PlayerState = Model.player_states.get_state(player_id)
			generate_layer_ores(player_state, background_rock, player_ore_gen_data, layer_num)


## Given ore generation data, generate the ores for the given player state and layer number by
## filling out the tile map layer with the appropriate ores.
func generate_layer_ores(
	player_state: PlayerState, background_rock: Types.Ore, generation_data: Array, layer_num: int
) -> void:
	# first, make a random circle for each ore
	var ore_circles: Array[OreCircle]
	var layer_start_y: int = layer_num * num_rows_layer
	var layer_end_y: int = layer_start_y + num_rows_layer
	for ore_gen_data: OreGenerationResource in generation_data:
		var ore: Types.Ore = ore_gen_data.ore
		var radius: float = ore_gen_data.size

		var random_center: Vector2 = Vector2(
			randf_range(0, num_cols),
			randf_range(layer_start_y, layer_end_y),
		)
		var random_radius: float = randfn(radius, 0.3)
		ore_circles.append(OreCircle.new(ore, random_center, random_radius))

	var ores: OreModel = player_state.ores
	# then, for each tile in the tilemap
	for grid_position: Vector2i in layer_grid_positions(layer_num):
		var center_of_tile: Vector2 = Vector2(grid_position) + Vector2(0.5, 0.5)
		# if no ore is found, write the background rock
		var closest_ore: Types.Ore = background_rock
		var closest_distance: float = 9999.0

		# find the ore circle that is closest to the tile that is within the radius of the ore circle
		for ore_circle: OreCircle in ore_circles:
			var dist_to_center: float = center_of_tile.distance_to(ore_circle.center)
			if dist_to_center < ore_circle.radius and dist_to_center < closest_distance:
				closest_ore = ore_circle.ore
				closest_distance = dist_to_center

		# set the tile to whatever we did or didn't find
		ores.set_ore(grid_position, closest_ore)


# Given the layer number, return an iterator that goes through every grid position in that layer.
func layer_grid_positions(layer_num: int):
	return LayerGridPositionIterator.new(self, layer_num)


## Set up the dictionary to associate an empty array to each player id in the game.
func _init_ores_for_each_player() -> Dictionary[int, Array]:
	# note: nested types are disallowed, so must be Array instead of Array[OreGenerationResource]
	var ores_for_each_player: Dictionary[int, Array]
	for player_id in ConnectionSystem.get_player_id_list():
		ores_for_each_player[player_id] = [] as Array[OreGenerationResource]
	return ores_for_each_player


## Defines a circle filled with the specified ore.
class OreCircle:
	var ore: Types.Ore
	var center: Vector2
	var radius: float

	func _init(o, c, r) -> void:
		ore = o
		center = c
		radius = r


# Iterate through all grid positions in the given layer, left to right, top to bottom.
class LayerGridPositionIterator:
	# The specific layer number to iterate through.
	var layer_num: int

	# The current grid position of the iterator.
	var grid_position: Vector2i

	# Number of rows in each layer.
	var _num_rows_layer: int

	# Number of columns.
	var _num_cols: int

	# The last grid position that the iterator should end at.
	var _ending_grid_position: Vector2i

	func _init(world_gen_model: Node, new_layer_num: int) -> void:
		layer_num = new_layer_num
		_num_rows_layer = world_gen_model.num_rows_layer
		_num_cols = world_gen_model.num_cols
		_ending_grid_position = Vector2i(0, (new_layer_num + 1) * _num_rows_layer)

	# Return whether the iterator should continue.
	func should_continue() -> bool:
		return grid_position != _ending_grid_position

	func _iter_init(_iter: Array) -> bool:
		grid_position = Vector2i(0, layer_num * _num_rows_layer)
		return should_continue()

	func _iter_next(_iter: Array) -> bool:
		grid_position.x += 1
		if grid_position.x == _num_cols:
			grid_position.x = 0
			grid_position.y += 1
		return should_continue()

	func _iter_get(_iter: Variant) -> Variant:
		return grid_position

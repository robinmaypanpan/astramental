extends Control

# multiplayer properties
var owner_id: int
var player: ConnectionSystem.NetworkPlayer

@onready var vertical_list := %VerticalListContainer
@onready var sky := %Sky
@onready var player_name_label := %PlayerNameLabel
@onready var factory_and_mine := %FactoryAndMine
@onready var player_tile_map: BuildingTileMap = %PlayerTileMap


func _ready() -> void:
	if ConnectionSystem.is_not_running_network():
		owner_id = 1
		ConnectionSystem.host_server()

	player = ConnectionSystem.get_player(owner_id)

	print("doing ready for %s (%s)" % [player.name, owner_id])

	var tile_size := 16 * WorldGenModel.tile_map_scale
	var board_width_px := tile_size * WorldGenModel.num_cols
	var layer_height_px := tile_size * WorldGenModel.layer_thickness
	# 1 factory layer + x mine layers
	var num_layers := WorldGenModel.get_num_mine_layers() + 1

	custom_minimum_size = Vector2i(board_width_px, 0)
	vertical_list.custom_minimum_size = Vector2i(board_width_px, 0)

	sky.custom_minimum_size = Vector2i(0, WorldGenModel.sky_height)
	player_name_label.text = "%s\n(%s)" % [player.name, player.index]

	factory_and_mine.custom_minimum_size = Vector2i(0, layer_height_px * num_layers)
	player_tile_map.tile_map_scale = WorldGenModel.tile_map_scale
	player_tile_map.layer_thickness = WorldGenModel.layer_thickness

	# Set up factory tiles to be all white tiles
	var white_tile_atlas_coordinates = Vector2i(0, 0)
	for x in range(WorldGenModel.num_cols):
		for y in range(WorldGenModel.layer_thickness):
			player_tile_map.set_background_tile(x, y, white_tile_atlas_coordinates)


## Defines a circle filled with the specified ore.
class OreCircle:
	var ore: Types.Ore
	var center: Vector2
	var radius: float

	func _init(o, c, r) -> void:
		ore = o
		center = c
		radius = r


## Set a tile in the model to the specified ore.
func _set_ore_tile(x: int, y: int, ore: Types.Ore) -> void:
	var atlas_coordinates := Ores.get_atlas_coordinates(ore)
	Model.set_ore_at(owner_id, x, y, ore)


## Given ore generation data, generate the ores for the given layer number by filling
## out the tile map layer with the appropriate ores.
func generate_ores(background_rock: Types.Ore, generation_data: Array, layer_num: int) -> void:
	# first, make a random circle for each ore
	var ore_circles: Array[OreCircle]

	var layer_start_y := layer_num * WorldGenModel.layer_thickness
	var layer_end_y := layer_start_y + WorldGenModel.layer_thickness
	for ore_gen_data: OreGenerationResource in generation_data:
		var ore := ore_gen_data.ore
		var radius := ore_gen_data.size

		var random_center := Vector2(
			randf_range(0, WorldGenModel.num_cols),
			randf_range(layer_start_y, layer_end_y),
		)
		var random_radius := randfn(radius, 0.3)
		ore_circles.append(OreCircle.new(ore, random_center, random_radius))

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
			_set_ore_tile(x, y, closest_ore)

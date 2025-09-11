extends Control

@onready var _VerticalListContainer := %VerticalListContainer
@onready var _Sky := %Sky
@onready var _FactoryAndMine := %FactoryAndMine
@onready var _PlayerNameLabel := %PlayerNameLabel
@onready var _FactoryAndMineTiles: BuildingTileMap = %FactoryAndMineTiles

# multiplayer properties
var owner_id : int
var player: ConnectionSystem.NetworkPlayer

var building_tile_maps: Array[BuildingTileMap]

# game board properties
@export var NumCols : int = 30
@export var LayerThickness : int = 10
@export var SkyHeight : int = 100
@export var TileMapScale : int = 2

func _ready() -> void:
	if ConnectionSystem.is_not_running_network():
		owner_id = 1
		ConnectionSystem.host_server()
		
	player = ConnectionSystem.get_player(owner_id)
	building_tile_maps = [_FactoryAndMineTiles]
		
	print("doing ready for %s (%s)" % [player.name, owner_id])

	var tile_size := 16 * TileMapScale
	var board_width_px := tile_size * NumCols
	var layer_height_px := tile_size * LayerThickness
	# 1 factory layer + x mine layers
	var num_layers := Ores.get_num_mine_layers() + 1

	custom_minimum_size = Vector2i(board_width_px, 0)
	_VerticalListContainer.custom_minimum_size = Vector2i(board_width_px, 0)

	_Sky.custom_minimum_size = Vector2i(0, SkyHeight)
	_PlayerNameLabel.text = "%s\n(%s)" % [player.name, player.index]

	_FactoryAndMine.custom_minimum_size = Vector2i(0, layer_height_px * num_layers)
	_FactoryAndMineTiles.tile_map_scale = TileMapScale
	_FactoryAndMineTiles.layer_thickness = LayerThickness

	# Set up factory tiles to be all white tiles
	var white_tile_atlas_coordinates = Vector2i(0, 0)
	for x in range(NumCols):
		for y in range(LayerThickness):
			_FactoryAndMineTiles.set_background_tile(x, y, white_tile_atlas_coordinates)

## Defines a circle filled with the specified ore.
class OreCircle:
	var ore: Types.Ore
	var center: Vector2
	var radius: float

	func _init(o, c, r) -> void:
		ore = o
		center = c
		radius = r

## Set a tile in the tilemap to the specified ore.
func _set_ore_tile(x: int, y: int, ore: Types.Ore) -> void:
	var atlas_coordinates := Ores.get_atlas_coordinates(ore)
	_FactoryAndMineTiles.set_background_tile(x, y, atlas_coordinates)

## Given ore generation data, generate the ores for the given layer number by filling out the tile map layer with the appropriate ores.
func generate_ores(background_rock: Types.Ore, generation_data: Array, layer_num: int) -> void:
	# first, make a random circle for each ore
	var ore_circles: Array[OreCircle]

	var layer_start_y := layer_num * LayerThickness
	var layer_end_y := layer_start_y + LayerThickness
	for ore_gen_data: OreGenerationResource in generation_data:
		var ore := ore_gen_data.ore
		var radius := ore_gen_data.size
		
		var random_center := Vector2(
			randf_range(0, NumCols),
			randf_range(layer_start_y, layer_end_y),
		)
		var random_radius := randfn(radius, 0.3)
		ore_circles.append(OreCircle.new(ore, random_center, random_radius))
	
	# then, for each tile in the tilemap
	for x in range(NumCols):
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
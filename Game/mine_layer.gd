extends MarginContainer

var num_cols: int
var num_rows: int
var tile_map_scale: int

@onready var _mine_tiles: TileMapLayer = %MineTiles

class OreCircle:
	var ore: Ore.Type
	var center: Vector2
	var radius: float

	func _init(o, c, r) -> void:
		ore = o
		center = c
		radius = r

func _ready() -> void:
	_mine_tiles.scale = Vector2i(tile_map_scale, tile_map_scale)

	var tile_size_px = 16 * tile_map_scale
	custom_minimum_size = Vector2i(0, tile_size_px * num_rows)

func _set_tile(x: int, y: int, ore: Ore.Type) -> void:
	var tile_pos = Vector2i(x, y)
	var atlas_coordinates = Ores.get_atlas_coordinates(ore)
	_mine_tiles.set_cell(tile_pos, 0, atlas_coordinates)

func generate_ores(background_rock: Ore.Type, generation_data: Array) -> void:
	# first, make a random circle for each ore
	var ore_circles: Array[OreCircle]
	for ore_gen_data: OreGenerationResource in generation_data:
		var ore := ore_gen_data.ore
		var radius := ore_gen_data.size
		
		var random_center := Vector2(
			randf_range(0, num_cols),
			randf_range(0, num_rows),
		)
		var random_radius := randfn(radius, 0.3)
		ore_circles.append(OreCircle.new(ore, random_center, random_radius))
	
	# then, for each tile in the tilemap
	for x in range(num_cols):
		for y in range(num_rows):
			# find the ore circle that is closest to the tile: this will be the ore we write to the tilemap
			var center_of_tile := Vector2(x + 0.5, y + 0.5)
			# if no ore is found, write the background rock
			var closest_ore := background_rock
			var closest_distance := 9999.0

			for ore_circle in ore_circles:
				var dist_to_center := center_of_tile.distance_to(ore_circle.center)
				if dist_to_center < ore_circle.radius and dist_to_center < closest_distance:
					closest_ore = ore_circle.ore
					closest_distance = dist_to_center
			
			# set the tile to whatever we did or didn't find
			_set_tile(x, y, closest_ore)

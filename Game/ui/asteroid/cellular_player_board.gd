class_name CellularPlayerBoard
extends Control

## Texture to populate the factory with
@export var factory_texture: Texture

# multiplayer properties
var owner_id: int
var player: ConnectionSystem.NetworkPlayer
var ghost_building_position := Vector2i(-1,-1)

@onready var vertical_list := %VerticalListContainer
@onready var sky := %Sky
@onready var player_name_label := %PlayerNameLabel
@onready var factory_and_mine := %FactoryAndMine
@onready var game_grid: CellularGrid = %GameGrid


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

	game_grid.generate_grid(
		WorldGenModel.layer_thickness*(
			WorldGenModel.get_num_mine_layers() + 1),
			WorldGenModel.num_cols
	)

	# Set up factory tiles to be all white tiles
	for x in range(WorldGenModel.num_cols):
		for y in range(WorldGenModel.layer_thickness):
			game_grid.get_cell(y, x).set_background(factory_texture)


## Publicly sets the ore at the indicated location
func set_ore_at(x: int, y: int, ore_type: Types.Ore) -> void:
	var ore_resource: OreResource = Ores.get_ore_resource(ore_type)
	game_grid.get_cell(y, x).set_background(ore_resource.icon)


## Hide all buildings on the grid
func clear_buildings() -> void:
	for cell:Cell in game_grid.all_cells():
		cell.set_icon(null)


## Place a building at the desired location
func place_building(position: Vector2i, building_id: String) -> void:
	var building: BuildingResource = Buildings.get_by_id(building_id)
	game_grid.get_cell(position.y, position.x).set_icon(building.icon)


## Set the position of the ghost building at the indicated position
func set_ghost_building(x: int, y:int, building_id: String) -> void:
	clear_ghost_building()
	ghost_building_position = Vector2i(x,y)
	var building: BuildingResource = Buildings.get_by_id(building_id)
	game_grid.get_cell(y, x).set_ghost(building.icon)


## Remove the ghost building from its position
func clear_ghost_building() -> void:
	if ghost_building_position.y >= 0:
		game_grid.get_cell(ghost_building_position.y, ghost_building_position.x).set_ghost(null)
		ghost_building_position = Vector2i(-1,-1)


## Returns true if the mouse is over the factory or mine
func is_mouse_over_factory_or_mine() -> bool:
	var mouse_position := game_grid.get_local_mouse_position()
	return game_grid.get_rect().has_point(mouse_position)


## Returns the coordinates of the grid if the mouse is over them.
func get_mouse_grid_position() -> Vector2i:
	var mouse_position := game_grid.get_local_mouse_position()
	return game_grid.get_cell_coordinates_at_local_point(mouse_position)


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

## Set a tile in the model to the specified ore.
func _set_ore_tile(x: int, y: int, ore: Types.Ore) -> void:
	Model.set_ore_at(owner_id, x, y, ore)

## Defines a circle filled with the specified ore.
class OreCircle:
	var ore: Types.Ore
	var center: Vector2
	var radius: float

	func _init(o, c, r) -> void:
		ore = o
		center = c
		radius = r

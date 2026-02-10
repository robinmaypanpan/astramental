class_name CellularPlayerBoard
extends Control

## When true, this board is not initialized and instead just does nothing
@export var is_dummy: bool = false

# multiplayer properties
var owner_id: int
var player: ConnectionSystem.NetworkPlayer
var ghost_building_position := Vector2i(-1, -1)

@onready var vertical_list := %VerticalListContainer
@onready var sky := %Sky
@onready var player_name_label := %PlayerNameLabel
@onready var factory_and_mine := %FactoryAndMine
@onready var game_grid: CellularGrid = %GameGrid

## Information about the factory that we can use to render the factory floor
@onready var factory_resource: FactoryResource = preload("res://Game/data/factory_floor.tres")


func _ready() -> void:
	if is_dummy:
		# Do nothing if I'm a dummy
		return

	if ConnectionSystem.is_not_running_network():
		owner_id = 1
		ConnectionSystem.host_server()

	player = ConnectionSystem.get_player(owner_id)
	name = "PlayerBoard%d" % owner_id

	player_name_label.text = "%s\n(%s)" % [player.name, player.index]

	var world_gen_model: WorldGenModel = Model.world_gen_model
	game_grid.generate_grid(
		world_gen_model.num_cols,
		world_gen_model.num_rows
	)

	# Set up factory tiles to be all white tiles
	for x in range(world_gen_model.num_cols):
		for y in range(world_gen_model.num_rows_layer):
			game_grid.get_cell(x, y).set_background(factory_resource.icon, false)


## Publicly sets the ore at the indicated location
func set_ore_at(x: int, y: int, ore_type: Types.Ore) -> void:
	var ore_resource: OreResource = Ores.get_ore_resource(ore_type)
	var cell: Cell = game_grid.get_cell(x, y)
	cell.set_background(ore_resource.icon, true)
	



## Hide all buildings on the grid
func clear_buildings() -> void:
	for cell: Cell in game_grid.all_cells():
		cell.set_icon(null)


## Returns the player ID that owns this board
func get_owning_player_id() -> int:
	return owner_id


## Place a building at the desired location
func place_building(grid_position: Vector2i, building_id: String) -> void:
	var building: BuildingResource = Buildings.get_by_id(building_id)
	game_grid.get_cell(grid_position.x, grid_position.y).set_icon(building.icon)


## Clear all the heat bars
func clear_heat_bars() -> void:
	for cell: Cell in game_grid.all_cells():
		cell.clear_heat_bar()


## Set the heat bar for the given cell.
func set_heat_bar(pos: Vector2i, heat: float, heat_capacity: float) -> void:
	game_grid.get_cell(pos.x, pos.y).set_heat_bar(heat, heat_capacity)


## Set the heat state for the given cell.
func set_heat_state(grid_position: Vector2i, heat_state: Types.HeatState) -> void:
	game_grid.get_cell(grid_position.x, grid_position.y).set_heat_state(heat_state)


## Set the position of the ghost building at the indicated position
func set_ghost_building(pos: Vector2i, building_id: String) -> void:
	clear_ghost_building()
	ghost_building_position = pos
	var building: BuildingResource = Buildings.get_by_id(building_id)
	game_grid.get_cell_at(pos).set_ghost(building.icon)


## Remove the ghost building from its position
func clear_ghost_building() -> void:
	if ghost_building_position.y >= 0:
		game_grid.get_cell_at(ghost_building_position).set_ghost(null)
		ghost_building_position = Vector2i(-1, -1)


## Returns true if the mouse is over the factory or mine
func is_mouse_over_factory_or_mine() -> bool:
	var mouse_position := game_grid.get_local_mouse_position()
	return game_grid.get_rect().has_point(mouse_position)


## Returns the coordinates of the grid if the mouse is over them.
func get_mouse_grid_position() -> Vector2i:
	var mouse_position := game_grid.get_local_mouse_position()
	return game_grid.get_cell_coordinates_at_local_point(mouse_position)
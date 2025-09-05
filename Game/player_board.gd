extends Control

@onready var _VerticalListContainer := %VerticalListContainer
@onready var _Sky := %Sky
@onready var _FactoryFloor := %FactoryFloor
@onready var _PlayerNameLabel := %PlayerNameLabel
@onready var _FactoryTiles: BuildingTileMap = %FactoryTiles

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
	building_tile_maps = [_FactoryTiles]
		
	print("doing ready for %s (%s)" % [player.name, owner_id])

	var tile_size := 16 * TileMapScale
	var board_width_px := tile_size * NumCols
	var layer_height_px := tile_size * LayerThickness

	custom_minimum_size = Vector2i(board_width_px, 0)
	_VerticalListContainer.custom_minimum_size = Vector2i(board_width_px, 0)

	_Sky.custom_minimum_size = Vector2i(0, SkyHeight)
	_PlayerNameLabel.text = "%s\n(%s)" % [player.name, player.index]

	_FactoryFloor.custom_minimum_size = Vector2i(0, layer_height_px)

	# Set up factory tiles to be all white tiles
	for x in range(NumCols):
		for y in range(LayerThickness):
			_FactoryTiles.set_background_tile(x, y, Vector2i(0, 0))

## Given an instantiated mine layer, add it as a child to this board.
func add_mine_layer(mine_layer: Node) -> void:
	_VerticalListContainer.add_child(mine_layer)
	building_tile_maps.append(mine_layer.MineTiles)

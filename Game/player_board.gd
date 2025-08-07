extends Control

@onready var _VerticalListContainer := %VerticalListContainer
@onready var _Sky := %Sky
@onready var _FactoryFloor := %FactoryFloor
@onready var _Mine := %Mine
@onready var _PlayerNameLabel := %PlayerNameLabel
@onready var _MineTiles := %MineTiles
@onready var _FactoryTiles := %FactoryTiles

# multiplayer properties
var owner_id : int
var player: ConnectionSystem.NetworkPlayer

# game board properties
@export var NumCols : int = 30
@export var LayerThickness : int = 10
@export var NumMineLayers : int = 1
@export var SkyHeight : int = 100
@export var TileMapScale : int = 2

func _ready() -> void:	
	if ConnectionSystem.is_not_running_network():
		owner_id = 1
		ConnectionSystem.host_server()
		
	var player = ConnectionSystem.get_player(owner_id)
		
	print("doing ready for %s (%s)" % [player.name, owner_id])

	var tile_size := 16 * TileMapScale
	var board_width_px := tile_size * NumCols
	var layer_height_px := tile_size * LayerThickness

	custom_minimum_size = Vector2i(board_width_px, 0)
	_VerticalListContainer.custom_minimum_size = Vector2i(board_width_px, 0)
	_Sky.custom_minimum_size = Vector2i(0, SkyHeight)
	_FactoryFloor.custom_minimum_size = Vector2i(0, layer_height_px)
	_Mine.custom_minimum_size = Vector2i(0, layer_height_px)
	_PlayerNameLabel.text = "%s\n(%s)" % [player.name, player.index]

	for x in range(NumCols):
		for y in range(LayerThickness):
			var tileCoords := Vector2i(x, y)
			var randomOreId=randi_range(1,5)
			
			_MineTiles.set_cell(tileCoords, 0, Vector2i(randomOreId,0))
			_FactoryTiles.set_cell(tileCoords, 0, Vector2i(0,0))

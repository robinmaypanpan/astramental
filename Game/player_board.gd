extends VBoxContainer

@export var MineMap : TileMapLayer
@export var FactoryMap : TileMapLayer

# multiplayer properties
@export var OwnerId : int
@export var OwnerName : String

# game board properties
@export var NumCols : int = 30
@export var LayerThickness : int = 10
@export var NumMineLayers : int = 1
@export var SkyHeight : int = 100
@export var TileMapScale : int = 2

func _ready() -> void:
	print("doing ready for %s (%s)" % [OwnerName, OwnerId])

	var tile_size := 16 * TileMapScale
	var board_width_px := tile_size * NumCols
	var layer_height_px := tile_size * LayerThickness

	custom_minimum_size = Vector2i(board_width_px, 0)
	$Sky.custom_minimum_size = Vector2i(0, SkyHeight)
	$FactoryFloor.custom_minimum_size = Vector2i(0, layer_height_px)
	$Mine.custom_minimum_size = Vector2i(0, layer_height_px)
	%PlayerNameLabel.text = "%s\n(%s)" % [OwnerName, OwnerId]

	for x in range(NumCols):
		for y in range(LayerThickness):
			var tileCoords := Vector2i(x, y)
			var randomOreId=randi_range(1,5)
			
			MineMap.set_cell(tileCoords, 0, Vector2i(randomOreId,0))
			FactoryMap.set_cell(tileCoords, 0, Vector2i(0,0))

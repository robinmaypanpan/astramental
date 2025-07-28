extends Control

@export var MineMap : TileMapLayer
@export var FactoryMap : TileMapLayer

@export var NumCols : int = 30
@export var LayerThickness : int = 10
@export var NumMineLayers : int = 1
@export var SkyHeight : int = 100

func _ready() -> void:
	randomize()
	for x in range(NumCols):
		for y in range(LayerThickness):
			var tileCoords := Vector2i(x, y)
			var randomOreId=randi_range(1,5)
			
			MineMap.set_cell(tileCoords, 0, Vector2i(randomOreId,0))
			FactoryMap.set_cell(tileCoords, 0, Vector2i(0,0))

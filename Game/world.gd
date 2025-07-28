extends Node2D

@export var MineAndFactoryMap : TileMapLayer

func _ready() -> void:
	randomize()
	for i in range(60):
		for j in range(60):
			var tileCoords := Vector2i(i, j)
			var randomOreId=randi_range(1,5)
			
			MineAndFactoryMap.set_cell(tileCoords, 0, Vector2i(randomOreId,0))

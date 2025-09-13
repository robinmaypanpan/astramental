class_name PlayerState extends Node

## The player id, assigned by the multiplayer controller.
@export var id: int
## The player index, which starts at 1 for the server and increases by 1 for each successive player.
@export var index: int
## The amount of each item that this player currently has.
@export var items: Dictionary[Types.Item, float]
## Contains the layout of the ores for each player.
## Stored as a 1D array that we index into with Model.get_ore_at and Model.set_ore_at.
@export var ores_layout: Array[Types.Ore]

@export var buildings_list: Array[PlacedBuilding]

func _ready() -> void:
	var num_layers = WorldGenModel.get_num_mine_layers()
	var layer_size = WorldGenModel.num_cols * WorldGenModel.layer_thickness
	ores_layout.resize(num_layers * layer_size)

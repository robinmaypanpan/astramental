class_name PlayerState extends Node

## The player id, assigned by the multiplayer controller.
@export var id:int
## The player index, which starts at 1 for the server and increases by 1 for each successive player.
@export var index:int
## The amount of each item that this player currently has.
@export var items: Dictionary[Types.Item, float]
## 2D array of ore data.
@export var ores_layout: Array[Types.Ore]

func _ready() -> void:
    var num_layers = WorldGenModel.get_total_num_layers()
    var layer_size = WorldGenModel.num_cols * WorldGenModel.layer_thickness
    ores_layout.resize(num_layers * layer_size)
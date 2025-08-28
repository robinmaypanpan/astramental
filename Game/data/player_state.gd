class_name PlayerState extends Node

## The player id, assigned by the multiplayer controller.
@export var id:int
## The player index, which starts at 1 for the server and increases by 1 for each successive player.
@export var index:int
## The amount of each item that this player currently has.
@export var items: Dictionary[Item.Type, float]

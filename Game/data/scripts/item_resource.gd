class_name ItemResource
extends Resource

@export var icon: Texture2D
## Whether the resource can be traded or not.
@export var can_trade: bool = true
## The money you get for selling one unit of the resource.
@export var sell_value: float = 0
## A user facing name for this item
@export var display_name: String = "Unnamed Resource"
## A user facing description to display on the tooltip
@export var description: String = "No description available."

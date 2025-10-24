class_name CellTooltip
extends Tooltip

@onready var cell_name_label: Label = %CellName
@onready var cell_description_label: Label = %CellDescription
@onready var cell_icon: TextureRect = %CellIcon


## Override the parent class's tooltip source
func set_tooltip_source(node: Control) -> void:
	assert(node is Cell, "CellTooltip can only accept Cell nodes as tooltip sources")
	var cell: Cell = node as Cell

	# Get the item that is located at that position in the cell
	var cell_position: Vector2i = cell.grid_position

	# For now just set the name label to the cell name
	cell_name_label.text = "Hello World"

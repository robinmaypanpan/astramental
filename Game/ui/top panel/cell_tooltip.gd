class_name CellTooltip
extends Tooltip

@onready var cell_name_label: Label = %CellName
@onready var cell_description_label: Label = %CellDescription
@onready var cell_icon: TextureRect = %CellIcon


## Override the parent class's tooltip source
func set_tooltip_source(node: Control) -> void:
	assert(node is Cell, "CellTooltip can only accept Cell nodes as tooltip sources")
	var cell: Cell = node as Cell

	# Get the ore that is located at that position in the cell
	var cell_position: Vector2i = cell.grid_position

	var player_id: int = cell.get_owning_player_id()

	var ore_type: Types.Ore = Model.get_ore_at(player_id, cell_position.x, cell_position.y)
	var ore_resource: OreResource = Ores.get_ore_resource(ore_type)
	cell_name_label.text = ore_resource.display_name
	cell_description_label.text = ore_resource.description
	cell_icon.texture = ore_resource.icon

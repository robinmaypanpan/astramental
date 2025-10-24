class_name CellTooltip
extends Tooltip

@onready var cell_name_label: Label = %CellName
@onready var cell_description_label: Label = %CellDescription
@onready var cell_icon: TextureRect = %CellIcon
@onready var building_info: Control = %BuildingInfo
@onready var building_name_label: Label = %BuildingName
@onready var building_description_label: Label = %BuildingDescription
@onready var building_icon: TextureRect = %BuildingIcon
@onready var divider: Control = %Divider

@onready var factory_resource: FactoryResource = preload("res://Game/data/factory_floor.tres")


## Override the parent class's tooltip source
func set_tooltip_source(node: Control) -> void:
	assert(node is Cell, "CellTooltip can only accept Cell nodes as tooltip sources")
	var cell: Cell = node as Cell

	# Handle the ore/floor first, since it is always there
	var cell_position: Vector2i = cell.grid_position

	var player_id: int = cell.get_owning_player_id()

	var layer_type: Types.Layer = WorldGenModel.get_layer_type(cell_position.y)

	match layer_type:
		Types.Layer.MINE:
			var ore_type: Types.Ore = Model.get_ore_at(player_id, cell_position.x, cell_position.y)
			var ore_resource: OreResource = Ores.get_ore_resource(ore_type)
			cell_name_label.text = ore_resource.display_name
			cell_description_label.text = ore_resource.description
			cell_icon.texture = ore_resource.icon
		Types.Layer.FACTORY:
			cell_name_label.text = factory_resource.display_name
			cell_description_label.text = factory_resource.description
			cell_icon.texture = factory_resource.icon

	# Now we check to see if we have a building
	var building_id: String = Model.get_building_at(
		PlayerGridPosition.new(player_id, cell_position)
	)

	if building_id == "":
		show_building_info(false)
	else:
		var building: BuildingResource = Buildings.get_by_id(building_id)
		building_name_label.text = building.name
		building_description_label.text = building.description
		building_icon.texture = building.icon
		show_building_info(true)


## Shows or hides building information in the tooltip
func show_building_info(show: bool) -> void:
	building_info.visible = show
	divider.visible = show

class_name CellTooltip
extends Tooltip

@export
var production_indicator_format: String = "Produces [img=center,center,32x32]%s[/img] when mined"

@onready var cell_name_label: Label = %CellName
@onready var cell_description_label: Label = %CellDescription
@onready var cell_icon: TextureRect = %CellIcon

@onready var production_indicator: RichTextLabel = %ProductionIndicator

@onready var building_info: Control = %BuildingInfo
@onready var building_name_label: Label = %BuildingName
@onready var building_description_label: Label = %BuildingDescription
@onready var building_icon: TextureRect = %BuildingIcon

@onready var energy_usage_container: Control = %EnergyUsage
@onready var energy_direction_label: Label = %EnergyDirection
@onready var energy_quantity_label: Label = %EnergyQuantity

@onready var divider: Control = %Divider

@onready var factory_resource: FactoryResource = preload("res://Game/data/factory_floor.tres")


func _ready() -> void:
	show_building_info(false)


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

			var ore_yield: Types.Item = Ores.get_yield(ore_type)
			var yield_item_resource: ItemResource = Items.get_info(ore_yield)
			production_indicator.text = (
				production_indicator_format % yield_item_resource.icon.resource_path
			)
			production_indicator.show()
		Types.Layer.FACTORY:
			production_indicator.hide()
			cell_name_label.text = factory_resource.display_name
			cell_description_label.text = factory_resource.description
			cell_icon.texture = factory_resource.icon

	# Now we check to see if we have a building
	var building_entity: BuildingEntity = Model.get_building_at(player_id, cell_position)

	if building_entity == null:
		show_building_info(false)
	else:
		var building_resource: BuildingResource = building_entity.get_resource()
		building_name_label.text = building_resource.name
		building_description_label.text = building_resource.description
		building_icon.texture = building_resource.icon

		# Show energy usage info if applicable
		var energy_component: EnergyComponent = (
			building_entity.get_component("EnergyComponent") as EnergyComponent
		)

		if energy_component == null || energy_component.energy_drain == 0.0:
			energy_usage_container.hide()
		else:
			var energy_usage: float = energy_component.energy_drain
			if energy_usage > 0:
				energy_direction_label.text = "Consumes"
				energy_quantity_label.text = "%0.2f" % energy_usage
			else:
				energy_direction_label.text = "Produces"
				energy_quantity_label.text = "%0.2f" % -energy_usage
			energy_usage_container.show()

		show_building_info(true)


## Shows or hides building information in the tooltip
func show_building_info(show: bool) -> void:
	building_info.visible = show
	divider.visible = show

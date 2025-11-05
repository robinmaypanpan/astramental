class_name BuildingTooltip
extends Tooltip

## Scene to use to populate Cost list
@export var item_cost_scene: PackedScene

@onready var building_name_label: Label = %BuildingName
@onready var building_description_label: Label = %BuildingDescription
@onready var building_icon: TextureRect = %BuildingIcon

@onready var cost_container: Container = %CostContainer

@onready var energy_usage_container: Control = %EnergyUsage
@onready var energy_direction_label: Label = %EnergyDirection
@onready var energy_quantity_label: Label = %EnergyQuantity


func _ready() -> void:
	show_energy_info(false)


## Override the parent class's tooltip source
func set_tooltip_source(node: Control) -> void:
	assert(
		node is BuildMenuItem,
		"BuildingTooltip can only accept BuildMenuItem nodes as tooltip sources"
	)
	var build_item: BuildMenuItem = node as BuildMenuItem

	var building_resource: BuildingResource = build_item.get_building_resource()

	# Set basic building info
	building_name_label.text = building_resource.name
	building_description_label.text = building_resource.description
	building_icon.texture = building_resource.icon

	# Show building costs
	populate_costs(building_resource.item_costs)

	# Show energy usage if applicable
	show_energy_usage(building_resource)


## Populate the cost container with item costs
func populate_costs(item_costs: Array[ItemCost]) -> void:
	clear_cost_container()

	for item_cost: ItemCost in item_costs:
		var new_item_cost: BuildMenuItemCost = item_cost_scene.instantiate()
		cost_container.add_child(new_item_cost)
		new_item_cost.set_item_cost(item_cost)


## Show energy usage information for the building
func show_energy_usage(building_resource: BuildingResource) -> void:
	var energy_component_data: EnergyComponentData = (
		building_resource.get_component_data("EnergyComponentData") as EnergyComponentData
	)

	if not energy_component_data:
		show_energy_info(false)
		return

	var energy_usage: float = energy_component_data.energy_drain

	if energy_usage == 0.0:
		show_energy_info(false)
	else:
		if energy_usage > 0:
			energy_direction_label.text = "Consumes"
			energy_quantity_label.text = "%0.2f" % energy_usage
		else:
			energy_direction_label.text = "Produces"
			energy_quantity_label.text = "%0.2f" % -energy_usage
		show_energy_info(true)


## Clear all items from the cost container
func clear_cost_container() -> void:
	for child in cost_container.get_children():
		cost_container.remove_child(child)
		child.queue_free()


## Shows or hides energy information in the tooltip
func show_energy_info(should_show: bool) -> void:
	energy_usage_container.visible = should_show

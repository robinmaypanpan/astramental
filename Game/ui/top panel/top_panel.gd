extends Panel

@onready var tooltip_container: Container = %TooltipContainer
@onready var cell_tooltip: Tooltip = %CellTooltip
@onready var building_tooltip: Tooltip = %BuildingTooltip


func _ready() -> void:
	Globals.tooltip_target_changed.connect(on_tooltip_target_changed)
	set_visible_tooltip(null)


## Fires whenever the tooltip target changes
func on_tooltip_target_changed(control_node: Control):
	# TODO: Initialize to a fallback tooltip

	var next_tooltip: Tooltip = null
	
	if control_node is BuildMenuItem:
		next_tooltip = building_tooltip

	if control_node is Cell:
		next_tooltip = cell_tooltip

	if next_tooltip != null:
		next_tooltip.set_tooltip_source(control_node)

	# When next_tooltip is null, all tooltips are hidden
	set_visible_tooltip(next_tooltip)


## Used to exclusively show one tooltip at a time
func set_visible_tooltip(tooltip: Tooltip) -> void:
	for child in tooltip_container.get_children():
		child.hide()

	if tooltip != null:
		tooltip.show()

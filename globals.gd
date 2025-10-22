extends Node

var settings: SettingsResource

## Stores the current target of the tooltip
var tooltip_target: Control;

## Signal that fires when the tooltip target changes
signal tooltip_target_changed(tooltip_target);

func _ready() -> void:
	settings = preload("Game/data/settings.tres")

## Updates the tooltip target, posting an event if it has actually changed
func update_tooltip_target(new_target: Control):
	if tooltip_target != new_target:
		tooltip_target = new_target;
		tooltip_target_changed.emit(new_target);
	
## Clears the current tooltip target and publishes an event indicating that
## this has changed. If the optional target_to_remove parameter is passed in,
## the target will be cleared only if the the current target matches the specified
## Control. This can be helpful when trying to hide and show a specific element
## of the screen.
func clear_tooltip_target(target_to_remove: Control):
	if tooltip_target == null:
		# Nothing to do here
		return;
		
	if tooltip_target == target_to_remove || target_to_remove == null:
		# If this is the target, or we don't have a target to remove...
		tooltip_target = null;
		tooltip_target_changed.emit(null);
		
	

class_name OreStorageSystem
extends BuildingComponentSystem
## System responsible for calculating and updating storage caps.

## For each item, get its storage cap.
var _storage_caps: Dictionary[Types.Item, float]


func _reset_numbers() -> void:
	# get_storage_caps() does .duplicate(), so it's fine to assign it like this
	_storage_caps = Globals.settings.get_storage_caps()


## Calculate storage caps for this upcoming tick of production.
func update() -> void:
	# First, reset our numbers we had from last tick
	_reset_numbers()

	# Iterate through StorageComponents and calculate caps
	var storage_components: Array = component_manager.get_components_by_type("StorageComponent")
	for storage_component: StorageComponent in storage_components:
		var storage_cap_changes: Dictionary[Types.Item, float] = storage_component.storage_cap_changes
		for item: Types.Item in storage_cap_changes.keys():
			var amount: float = storage_cap_changes[item]
			_storage_caps[item] += amount

	# update storage caps
	player_state.items.storage_caps.set_all(_storage_caps)

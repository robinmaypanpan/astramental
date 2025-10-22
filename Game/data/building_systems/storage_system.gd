class_name StorageSystem
extends Node
## System responsible for calculating and updating storage caps.

## For each player, get the storage cap for each item.
## Stored as a nested Dictionary[int, Dictionary[Types.Item, float]]
var _storage_caps: Dictionary[int, Dictionary]


## Get storage cap for this player and item type.
func get_storage_cap(player_id: int, item: Types.Item) -> float:
	return _storage_caps[player_id][item]


## Add the amount given to the existing storage cap for that item.
func add_storage_cap(player_id: int, item: Types.Item, amount: float) -> void:
	_storage_caps[player_id][item] += amount


## Set the ore production for all players and ores back to the defaults.
func _reset_numbers() -> void:
	var player_ids = ConnectionSystem.get_player_id_list()
	for player_id: int in player_ids:
		_storage_caps[player_id] = Globals.settings.get_storage_caps()


## Calculate ore production for this upcoming tick of production.
## Dependent on EnergySystem for energy satisfaction numbers.
func update() -> void:
	# First, reset our numbers we had from last tick
	_reset_numbers()

	# Iterate through StorageComponents and calculate caps
	var storage_components: Array = ComponentManager.get_components("StorageComponent")
	for storage_component: StorageComponent in storage_components:
		var player_id: int = storage_component.building_entity.player_id
		var storage_cap_changes: Dictionary[Types.Item, float] = storage_component.storage_cap_changes
		for item: Types.Item in storage_cap_changes.keys():
			var amount: float = storage_cap_changes[item]
			add_storage_cap(player_id, item, amount)

	# update storage caps
	for player_id: int in ConnectionSystem.get_player_id_list():
		for item: int in Types.Item.values():
			var new_cap: float = get_storage_cap(player_id, item)
			Model.set_storage_cap(player_id, item, new_cap)

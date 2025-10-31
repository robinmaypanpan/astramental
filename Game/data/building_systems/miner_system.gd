class_name MinerSystem
extends Node
## System responsible for determining how much ore is being mined.

## For each player, get the amount of ore each player is producing per second this tick.
## Stored as a nested Dictionary[int, Dictionary[Types.Ore, float]]
var _ore_production: Dictionary[int, Dictionary]


## Get ore production for this player & ore.
func get_ore_production(player_id: int, ore: Types.Ore) -> float:
	return _ore_production[player_id][ore]


## Add the amount given to the existing ore production for that player & ore.
func add_ore_production(player_id: int, ore: Types.Ore, amount: float) -> void:
	_ore_production[player_id][ore] += amount


## Set the ore production for all players and ores back to 0.
func _reset_numbers() -> void:
	var player_ids = ConnectionSystem.get_player_id_list()
	for player_id: int in player_ids:
		_ore_production[player_id] = {}
		var player_ore_production: Dictionary = _ore_production[player_id]
		for ore in Types.Ore.values():
			player_ore_production[ore] = 0.0


## Calculate ore production for this upcoming tick of production.
## Dependent on EnergySystem for energy satisfaction numbers.
func update() -> void:
	# First, reset our numbers we had from last tick
	_reset_numbers()

	# Iterate through MinerComponents and calc production
	var miner_components: Array = ComponentManager.get_components("MinerComponent")
	for miner_component: MinerComponent in miner_components:
		var building_entity: BuildingEntity = miner_component.building_entity
		var heat_component: HeatComponent = building_entity.get_component("HeatComponent")
		if heat_component.heat_state == Types.HeatState.OVERHEATED:
			continue  # can't mine if you're overheated
		var player_id: int = building_entity.player_id
		var ore: Types.Ore = miner_component.ore_under_miner

		# account for energy satisfaction slowing down buildings
		var mining_amount: float = miner_component.mining_speed
		var energy_satisfaction: float = Model.get_energy_satisfaction(player_id)
		mining_amount *= energy_satisfaction

		add_ore_production(player_id, ore, mining_amount)

	# Figure out ore production this tick and update numbers for each ore
	for player_id: int in ConnectionSystem.get_player_id_list():
		for ore: int in Types.Ore.values():
			# figure ore production this tick
			var ore_production_per_sec: float = get_ore_production(player_id, ore)
			var update_interval: float = Globals.settings.update_interval
			var ore_production_this_tick: float = ore_production_per_sec * update_interval

			# figure out what new ore count should be
			var ore_item: Types.Item = Ores.get_yield(ore)
			var current_ore: float = Model.get_item_count(player_id, ore_item)
			var new_ore: float = current_ore + ore_production_this_tick
			# TODO: move this code to update_item_count, as this doesn't belong here
			var max_ore: float = Model.get_storage_cap(player_id, ore_item)
			new_ore = min(new_ore, max_ore)

			# TODO: move this data out of the model. Consumers of this data can ask this system,
			# not the model.
			Model.set_item_count(player_id, ore_item, new_ore)
			Model.set_item_change_rate(player_id, ore_item, ore_production_per_sec)

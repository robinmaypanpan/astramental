class_name MinerSystem
extends Node
## System responsible for determining how much ore is being mined.

## For each player, get the amount of ore each player is producing per second this tick.
## This includes limitations on storage and reductions due to energy efficiency
var actual_ore_production: Dictionary[int, Dictionary]

## Stores the amount of ore production per second that the player is *trying* to produce
## for this much ore.
## This will not be impacted by things like energy efficiency or storage limits.
var desired_ore_production: Dictionary[int, Dictionary]


## Get ore production for this player & ore.
func get_actual_ore_production(player_id: int, ore: Types.Ore) -> float:
	return actual_ore_production[player_id][ore]


## Get ore production for this player & ore.
func get_desired_ore_production(player_id: int, ore: Types.Ore) -> float:
	return desired_ore_production[player_id][ore]


## Calculate ore production for this upcoming tick of production.
## Dependent on EnergySystem for energy satisfaction numbers.
func update() -> void:
	# First, reset our numbers we had from last tick
	_reset_numbers()

	# Iterate through MinerComponents and calc production
	var miner_components: Array = ComponentManager.get_components("MinerComponent")
	# Now calculate actual ore production based on reductions from other impacts
	for miner_component: MinerComponent in miner_components:
		update_ore_production(miner_component)

	# Finally, make the changes and updates
	for player_id: int in ConnectionSystem.get_player_id_list():
		for ore: int in Types.Ore.values():
			restrict_ore_production(player_id, ore)
			apply_ore_production(player_id, ore)


# PRIVATE METHODS
func apply_ore_production(player_id: int, ore: Types.Ore) -> void:
	var final_actual_production: float = actual_ore_production[player_id][ore]

	# figure out what new ore count should be
	var ore_item: Types.Item = Ores.get_yield(ore)
	Model.increase_item_count_apply_cap(
		player_id, ore_item, final_actual_production * Globals.settings.update_interval
	)

	Model.set_item_production(player_id, ore_item, final_actual_production)


# Limit ore production based on energy satisfaction and storage capacity
func restrict_ore_production(player_id: int, ore: Types.Ore) -> void:
	# Get the pre-restriction actual production of this ore
	var actual_production: float = actual_ore_production[player_id][ore]

	# account for energy satisfaction slowing down buildings
	var energy_satisfaction: float = Model.get_energy_satisfaction(player_id)
	actual_production *= energy_satisfaction

	# Limit production based on storage capacity
	var ore_item: Types.Item = Ores.get_yield(ore)
	var current_ore: float = Model.get_item_count(player_id, ore_item)
	var max_ore: float = Model.get_storage_cap(player_id, ore_item)
	var available_storage: float = max(max_ore - current_ore, 0.0)

	# See how much we wanted to produce this tick
	var actual_production_this_tick: float = actual_production * Globals.settings.update_interval

	# Limit that by the production capacity
	if actual_production_this_tick > available_storage:
		# We can't produce this much ore, limit it
		# NBD: We divide by the update interval because we'll be multiplying
		# by it later to get the per tick value
		actual_production = available_storage / Globals.settings.update_interval

	# Store the now-limited production back into the table
	actual_ore_production[player_id][ore] = actual_production


## Calculate the ore production based on this miner component, and then
func update_ore_production(miner_component: MinerComponent) -> void:
	var building_entity: BuildingEntity = miner_component.building_entity
	var player_id: int = building_entity.player_id
	var ore: Types.Ore = miner_component.ore_under_miner
	var mining_speed: float = miner_component.mining_speed

	# The desired ore production is what we want without modifications
	# It is a sort of "maximum" production value
	desired_ore_production[player_id][ore] += mining_speed

	var actual_production: float = mining_speed

	# Apply heat reduction
	var heat_component: HeatComponent = building_entity.get_component("HeatComponent")
	if heat_component.heat_state == Types.HeatState.OVERHEATED:
		# If the component is overheated, it's production drops to 0
		actual_production = 0.0
	else:
		# Otherwise, it's production is the mining speed
		actual_production = miner_component.mining_speed

	actual_ore_production[player_id][ore] += actual_production


## Set the ore production for all players and ores back to 0.
func _reset_numbers() -> void:
	var player_ids = ConnectionSystem.get_player_id_list()
	for player_id: int in player_ids:
		actual_ore_production[player_id] = {}
		desired_ore_production[player_id] = {}
		var player_ore_production: Dictionary = actual_ore_production[player_id]
		var player_desired_ore_production: Dictionary = desired_ore_production[player_id]
		for ore in Types.Ore.values():
			player_ore_production[ore] = 0.0
			player_desired_ore_production[ore] = 0.0

class_name NewMinerSystem
extends BuildingComponentSystem
## System responsible for determining how much ore is being mined.

## Get the amount of ore we are producing per second this tick.
## This includes limitations on storage and reductions due to energy efficiency.
var actual_ore_production: Dictionary[Types.Item, float]

## Stores the amount of ore production per second that we are *trying* to produce
## for this much ore.
## This will not be impacted by things like energy efficiency or storage limits.
var desired_ore_production: Dictionary[Types.Item, float]


## Calculate ore production for this upcoming tick of production.
## Dependent on EnergySystem for energy satisfaction numbers.
func update() -> void:
	# First, reset our numbers we had from last tick
	_reset_numbers()

	# Iterate through MinerComponents and calc production
	var miner_components: Array = component_manager.get_components_by_type("MinerComponent")
	# Now calculate actual ore production based on reductions from other impacts
	for miner_component: MinerComponent in miner_components:
		update_ore_production(miner_component)

	# Finally, make the changes and updates
	for ore: int in Types.Ore.values():
		restrict_ore_production(ore)
		apply_ore_production(ore)


# PRIVATE METHODS
func apply_ore_production(ore: Types.Ore) -> void:
	var final_actual_production: float = actual_ore_production[ore]

	# figure out what new ore count should be
	var ore_item: Types.Item = Ores.get_yield(ore)
	var items = player_state.items
	items.increase_item_count_apply_cap(
		ore_item, final_actual_production * Globals.settings.update_interval
	)

	items.production.set_for(ore_item, final_actual_production)


# Limit ore production based on energy satisfaction and storage capacity
func restrict_ore_production(ore: Types.Ore) -> void:
	# Get the pre-restriction actual production of this ore
	var actual_production: float = actual_ore_production[ore]

	# account for energy satisfaction slowing down buildings
	var energy_satisfaction: float = player_state.energy_satisfaction
	actual_production *= energy_satisfaction

	# Limit production based on storage capacity
	var ore_item: Types.Item = Ores.get_yield(ore)
	var items = player_state.items
	var current_ore: float = items.counts.get_for(ore_item)
	var max_ore: float = items.storage_caps.get_for(ore_item)
	var available_storage: float = max(max_ore - current_ore, 0.0)

	# See how much we wanted to produce this tick
	var actual_production_this_tick: float = actual_production * Globals.settings.update_interval

	# Limit that by the production capacity
	if actual_production_this_tick > available_storage:
		# We can't produce this much ore, limit it
		# NB: We divide by the update interval because we'll be multiplying
		# by it later to get the per tick value
		actual_production = available_storage / Globals.settings.update_interval

	# Store the now-limited production back into the table
	actual_ore_production[ore] = actual_production


## Calculate the ore production based on this miner component and update the appropriate tables
func update_ore_production(miner_component: MinerComponent) -> void:
	var building_entity: BuildingEntity = miner_component.building_entity
	var ore: Types.Ore = miner_component.ore_under_miner
	var mining_speed: float = miner_component.mining_speed

	# The desired ore production is what we want without modifications
	# It is a sort of "maximum" production value
	desired_ore_production[ore] += mining_speed

	var actual_production: float = 0.0

	# Apply heat reduction
	var heat_data: HeatData = player_state.building_heat.get_at_pos(building_entity.position)
	if heat_data.heat_state == Types.HeatState.OVERHEATED:
		# If the component is overheated, its production drops to 0
		actual_production = 0.0
	else:
		# Otherwise, its production is the mining speed
		actual_production = mining_speed

	actual_ore_production[ore] += actual_production


## Set the ore production for all ores back to 0.
func _reset_numbers() -> void:
	for ore in Types.Ore.values():
		actual_ore_production[ore] = 0.0
		desired_ore_production[ore] = 0.0

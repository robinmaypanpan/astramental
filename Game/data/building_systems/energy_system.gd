class_name EnergySystem
extends Node
## System responsible for calculating and updating energy reserves and energy satisfaction.

## For each player, how much energy they are producing per second this tick.
var energy_production: Dictionary[int, float]

## For each player, how much energy they are consuming per second this tick.
var energy_consumption: Dictionary[int, float]

## For each player, how much of the energy demand is being met by energy production,
## stored as a decimal from 0.0 to 1.0. Affects production speed of all buildings.
var energy_satisfaction: Dictionary[int, float]


## Reset the production/consumption numbers back to 0 for this upcoming tick of production.
func _reset_numbers() -> void:
	var player_ids = ConnectionSystem.get_player_id_list()
	for player_id in player_ids:
		energy_production[player_id] = 0.0
		energy_consumption[player_id] = 0.0
		# no need to reset energy_satisfaction as it's set once and forgotten


## Calculate energy production/consumption/satisfaction and adjust the amount of energy
## each player has correspondingly. Also publish energy satisfaction.
func update():
	# First, reset our numbers we had from last tick
	_reset_numbers()

	# Iterate through EnergyComponents and calculate consumption/production
	var energy_components: Array = ComponentManager.get_components("EnergyComponent")
	for component: EnergyComponent in energy_components:
		var energy_drain = component.energy_drain
		var player_id = component.building_entity.player_id
		if energy_drain > 0:
			energy_consumption[player_id] += energy_drain
		elif energy_drain < 0:
			# energy drain is negative, so need to subtract to make it positive
			energy_production[player_id] -= energy_drain

	# Update energy & energy satisfaction for each player and publish that information
	# to the model
	for player_id in ConnectionSystem.get_player_id_list():
		var player_consumption = energy_consumption[player_id]
		var player_production = energy_production[player_id]

		var energy_change_per_sec = player_production - player_consumption
		var update_interval = Globals.settings.update_interval
		# energy production/consumption is unaffected by satisfaction
		var energy_change_this_tick = energy_change_per_sec * update_interval

		var current_energy = Model.get_item_count(player_id, Types.Item.ENERGY)
		var new_energy = current_energy + energy_change_this_tick
		# TODO: move this code to update_item_count, as this doesn't belong here
		var max_energy = Model.get_storage_cap(player_id, Types.Item.ENERGY)
		new_energy = min(new_energy, max_energy)

		energy_satisfaction[player_id] = min(1.0, player_production / player_consumption)
		if new_energy < 0.0:
			new_energy = 0.0
			print("Out of energy; efficiency = %f / %f = %f"
				% [player_production, player_consumption, energy_satisfaction[player_id]])

		# TODO: move this data out of the model. Consumers of this data can ask this system,
		# not the model.
		Model.set_item_count(player_id, Types.Item.ENERGY, new_energy)
		Model.set_item_change_rate(player_id, Types.Item.ENERGY, energy_change_per_sec)
		Model.set_energy_satisfaction(player_id, energy_satisfaction[player_id])

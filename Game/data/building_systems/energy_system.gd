class_name EnergySystem
extends Node

var energy_production: Dictionary[int, float]
var energy_consumption: Dictionary[int, float]
var energy_satisfaction: Dictionary[int, float]

func _reset_numbers() -> void:
	var player_ids = ConnectionSystem.get_player_id_list()
	for player_id in player_ids:
		energy_production[player_id] = 0.0
		energy_consumption[player_id] = 0.0
		# no need to reset energy_satisfaction as it's set once and forgotten


func update():
	_reset_numbers()
	var energy_components: Array = ComponentManager.get_components(Types.BuildingComponent.ENERGY)
	for component: EnergyComponent in energy_components:
		var energy_drain = component.energy_drain
		var player_id = component.building_entity.player_id
		if energy_drain > 0:
			energy_consumption[player_id] += energy_drain
		elif energy_drain < 0:
			# energy drain is negative, so need to subtract to make it positive
			energy_production[player_id] -= energy_drain

	for player_id in ConnectionSystem.get_player_id_list():
		var our_consumption = energy_consumption[player_id]
		var our_production = energy_production[player_id]

		var energy_change_per_sec = our_production - our_consumption
		var update_interval = Globals.settings.update_interval
		var energy_change_this_tick = energy_change_per_sec * update_interval

		var current_energy = Model.get_item_count(player_id, Types.Item.ENERGY)

		var new_energy = current_energy + energy_change_this_tick
		## TODO: move this code to update_item_count, as this doesn't belong here
		var max_energy = Model.get_storage_limit(player_id, Types.Item.ENERGY)
		new_energy = min(new_energy, max_energy)

		energy_satisfaction[player_id] = min(1.0, our_production / our_consumption)
		if new_energy < 0.0:
			new_energy = 0.0
			print("Out of energy; efficiency = %f / %f = %f"
				% [our_production, our_consumption, energy_satisfaction[player_id]])

		Model.set_item_count(player_id, Types.Item.ENERGY, new_energy)
		Model.set_item_change_rate(player_id, Types.Item.ENERGY, energy_change_per_sec)
		Model.set_energy_satisfaction(player_id, energy_satisfaction[player_id])

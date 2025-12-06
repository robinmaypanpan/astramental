class_name NewEnergySystem
extends BuildingComponentSystem
## System responsible for calculating and updating energy reserves and energy satisfaction.

## For each player, how much of the energy demand is being met by energy production,
## stored as a decimal from 0.0 to 1.0. Affects production speed of all buildings.
var energy_satisfaction: float

## For each player, how much energy they are producing per second this tick.
var _energy_production: float

## For each player, how much energy they are consuming per second this tick.
var _energy_consumption: float


func _reset_numbers() -> void:
	_energy_production = 0.0
	_energy_consumption = 0.0
	energy_satisfaction = 1.0


## Calculate energy production/consumption/satisfaction and adjust the amount of energy
## each player has correspondingly. Also publish energy satisfaction.
func update(component_manager: NewComponentManager, player_state: PlayerState) -> void:
	# First, reset our numbers we had from last tick
	_reset_numbers()

	# Iterate through EnergyComponents and calculate consumption/production
	var energy_components: Array = component_manager.get_components("EnergyComponent")
	for component: EnergyComponent in energy_components:
		var energy_drain: float = component.energy_drain
		if energy_drain > 0:
			_energy_consumption += energy_drain
		elif energy_drain < 0:
			# energy drain is negative, so need to subtract to make it positive
			_energy_production -= energy_drain

	# Update energy & energy satisfaction for each player and publish that information
	# to the model
	var energy_change_per_sec: float = _energy_production - _energy_consumption
	var update_interval: float = Globals.settings.update_interval
	# energy production/consumption is unaffected by satisfaction
	var energy_change_this_tick: float = energy_change_per_sec * update_interval

	var items = player_state.items
	items.increase_item_count_apply_cap(Types.Item.ENERGY, energy_change_this_tick)

	energy_satisfaction = min(1.0, _energy_production / _energy_consumption)

	items.production.increase_for(Types.Item.ENERGY, _energy_production)
	items.consumption.increase_for(Types.Item.ENERGY, _energy_consumption)

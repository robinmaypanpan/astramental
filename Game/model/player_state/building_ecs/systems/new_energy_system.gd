class_name NewEnergySystem
extends BuildingComponentSystem
## System responsible for calculating and updating energy reserves and energy satisfaction.

## How much energy we are producing per second this tick.
var _energy_production: float

## How much energy we are consuming per second this tick.
var _energy_consumption: float


func _reset_numbers() -> void:
	_energy_production = 0.0
	_energy_consumption = 0.0


## Calculate energy production/consumption/satisfaction, and adjust our energy accordingly.
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

	# Figure out energy change this tick
	var energy_change_per_sec: float = _energy_production - _energy_consumption
	var update_interval: float = Globals.settings.update_interval
	# energy production/consumption is unaffected by satisfaction
	var energy_change_this_tick: float = energy_change_per_sec * update_interval

	# Publish updates to the model
	var items = player_state.items
	items.increase_item_count_apply_cap(Types.Item.ENERGY, energy_change_this_tick)

	# Set energy satisfaction directly, as it can be done in one step.
	player_state.energy_satisfaction = min(1.0, _energy_production / _energy_consumption)

	items.production.increase_for(Types.Item.ENERGY, _energy_production)
	items.consumption.increase_for(Types.Item.ENERGY, _energy_consumption)

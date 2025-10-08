class_name EnergySystem
extends Node

var energy_production: Dictionary[int, float]
var energy_consumption: Dictionary[int, float]
var energy_efficiency: Dictionary[int, float]

func _reset_numbers() -> void:
    var player_ids = ConnectionSystem.get_player_id_list()
    for player_id in player_ids:
        energy_production[player_id] = 0.0
        energy_consumption[player_id] = 0.0
        # no need to reset energy_efficiency as it's set once and forgotten


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
        var our_efficiency = min(1.0, our_production / our_consumption) 
        var energy_change_per_sec = our_production - our_consumption
        var current_energy = Model.get_item_count(player_id, Types.Item.ENERGY)

        # TODO: not correct, needs to take update interval + efficiency into account
        var new_energy = current_energy + energy_change_per_sec

        if new_energy < 0.0:
            new_energy = 0.0
            print("Out of energy; efficiency = %f / %f = %f"
                % [our_production, our_consumption, energy_efficiency[player_id]])

        Model.set_item_count(player_id, Types.Item.ENERGY, new_energy)
        Model.set_item_change_rate(player_id, Types.Item.ENERGY, energy_change_per_sec)

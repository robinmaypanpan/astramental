class_name MinerComponent
extends BuildingComponent

## How many resources this miner will mine per second.
@export var mining_speed: float:
    get:
        return _data.mining_speed

## Which ore is this miner mining?
@export var ore_under_miner: Types.Ore

func _init(
    in_unique_id: int,
    in_building_comp_data: BuildingComponentData,
    in_building_entity: BuildingEntity,
    in_ore_under_miner: Types.Ore):
    #start func
    super(in_unique_id, in_building_comp_data, in_building_entity)
    ore_under_miner = in_ore_under_miner
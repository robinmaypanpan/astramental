class_name MinerComponentData
extends BuildingComponentData

## How many resources this miner will mine per second.
@export var mining_speed: float


## TODO: define make_component()
func make_component(building_entity: BuildingEntity) -> MinerComponent:
    var player_id = building_entity.player_id
    var tile_pos = building_entity.position
    var ore_under_miner = Model.get_ore_at(player_id, tile_pos.x, tile_pos.y)
    return MinerComponent.new(self, building_entity, ore_under_miner)
class_name MinerComponentData
extends BuildingComponentData

## How many resources this miner will mine per second.
@export var mining_speed: float


func make_component(building_entity: BuildingEntity) -> MinerComponent:
    var player_id: int = building_entity.player_id
    var tile_pos: Vector2i = building_entity.position
    var ore_under_miner: Types.Ore = Model.get_ore_at(player_id, tile_pos.x, tile_pos.y)
    return MinerComponent.new(self, building_entity, ore_under_miner)
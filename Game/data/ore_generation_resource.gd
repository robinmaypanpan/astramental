class_name OreGenerationResource extends Resource

## The ore to generate.
@export var ore: Types.Ore
## Whether this ore should appear on all players' boards.
@export var generate_for_all_players: bool
## How big the ore blob should be.
@export_range(1,20) var size: float

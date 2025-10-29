class_name HeatComponent
extends BuildingComponent

## How much heat this building produces per second.
@export var heat_production: float:
	get:
		return _data.heat_production

## How much heat this building passively cools off per second.
## If set to 0, building will not cool off when reaching max heat until removed.
@export var heat_passive_cool_off: float:
	get:
		return _data.heat_passive_cool_off

## How much heat this building can hold before overheating.
## Once a building reaches the heat capacity, it will start cooling off at
## the cool off rate until it reaches 0 again.
@export var heat_capacity: float:
	get:
		return _data.heat_capacity

## Is this building a source, sink, or carrier of heat.
## Source: produces any heat.
## Sink: no production of heat, has heat capacity.
## Carrier: no production, passive cool off, or heat capacity. (not implemented yet)
var heat_building_type: Types.HeatBuilding

## Is this building a source.
var is_source: bool:
	get:
		return heat_building_type == Types.HeatBuilding.SOURCE

## Is this building a sink.
var is_sink: bool:
	get:
		return heat_building_type == Types.HeatBuilding.SINK

## How much heat this building currently holds.
var heat: float

## The current state of this building.
## Running: Building is working as expected.
##          Transitions to overheated when reaching its heat capacity.
## Overheated: Building was above heat capacity and doesn't produce heat or update normally.
##             Transitions to running when reaching 0 heat.
var heat_state: Types.HeatState


func _init(
	new_building_comp_data: BuildingComponentData, new_building_entity: BuildingEntity
) -> void:
	# start func
	super(new_building_comp_data, new_building_entity)

	if heat_production > 0.0:
		heat_building_type = Types.HeatBuilding.SOURCE
	elif heat_capacity > 0.0:  # heat_production == 0.0
		heat_building_type = Types.HeatBuilding.SINK
	elif heat_passive_cool_off == 0.0:  # heat_production == 0.0 and heat_capacity == 0.0
		heat_building_type = Types.HeatBuilding.CARRIER
	else:
		assert(false, "could not assign valid heat building type to this building")

	heat = 0.0
	heat_state = Types.HeatState.RUNNING

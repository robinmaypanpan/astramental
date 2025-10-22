class_name StorageComponentData
extends BuildingComponentData
## Defines how this building changes the storage caps on items.

## What the storage cap change is for each item it wishes to change storage cap on.
@export var storage_cap_changes: Dictionary[Types.Item, float]


func make_component(building_entity: BuildingEntity) -> StorageComponent:
    return StorageComponent.new(self, building_entity)
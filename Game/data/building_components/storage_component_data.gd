class_name StorageComponentData
extends BuildingComponentData
## Defines how this building changes the storage caps on items.

## What the storage cap change is for each item it wishes to change storage cap on.
@export var storage_cap_changes: Dictionary[Types.Item, float]


func make_component(unique_id: int, building_entity: BuildingEntity) -> StorageComponent:
	return StorageComponent.new(unique_id, self, building_entity)


func serialize() -> Dictionary:
	var serialized_component_data: Dictionary = super.serialize()
	serialized_component_data["storage_cap_changes"] = storage_cap_changes
	return serialized_component_data


static func from_serialized(serialized_component_data: Dictionary) -> StorageComponentData:
	var component_data = StorageComponentData.new()
	component_data.storage_cap_changes = serialized_component_data["storage_cap_changes"]
	return component_data
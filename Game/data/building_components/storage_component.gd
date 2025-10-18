class_name StorageComponent
extends BuildingComponent
## Instantiated component for keeping track of storage cap changes.

## What the storage cap change is for each item it wishes to change storage cap on.
@export var storage_cap_changes: Dictionary[Types.Item, float]:
    get:
        return _data.storage_cap_changes

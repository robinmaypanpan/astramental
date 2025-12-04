class_name ItemProperty
extends SyncProperty
## Node representing an item property like item_counts or storage_caps. Gets are done from the real
## copy, and sets are done to a shadow copy, that replicates to the real copy when the sync()
## method is called. The value_dict should be replicated across the server with a
## MultiplayerSynchronizer.


func _ready() -> void:
	value_client = [] as Array[float]
	value_client.resize(Types.Item.size())


## Get the real values of this property for the given item.
func get_for(item: Types.Item) -> float:
	return value_client[item]


## Set the shadow value of this property for the given item. Should only be called by the server.
func set_for(item: Types.Item, value: float) -> void:
	assert(multiplayer.is_server())
	value_client[item] = value


## Increase the shadow value of this property for the given item.
## Should only be called by the server.
func increase_for(item: Types.Item, amount: float) -> void:
	assert(multiplayer.is_server())
	value_client[item] += amount

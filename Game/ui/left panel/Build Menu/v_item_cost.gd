class_name BuildMenuItemCost
extends VBoxContainer

@onready var icon: TextureRect = %Icon
@onready var amount: Label = %Amount

## Sets the item cost to display in this scene
func set_item_cost(item_cost: ItemCost):
	var item_resource: ItemResource = Items.get_info(item_cost.item_id)
	icon.texture = item_resource.icon
	amount.text = "%d" % item_cost.quantity

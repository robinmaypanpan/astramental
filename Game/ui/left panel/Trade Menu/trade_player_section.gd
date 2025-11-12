class_name TradePlayerSection
extends Control
## Section of trade tab detailing all items being traded to a given player.

var trade_item_details_scene: PackedScene = preload(
	"res://Game/ui/left panel/Trade Menu/trade_item_details.tscn"
)

@onready var details_list_container: VBoxContainer = %DetailsListContainer
@onready var trade_player_header: TradePlayerHeader = %TradePlayerHeader


## Given an array of trade routes with receiving and sending player id identical, fill out the
## player header and item details for the trade routes.
func update_section(trade_routes: Array, trade_direction: Types.TradeDirection) -> void:
	_remove_item_details()
	if trade_routes.is_empty():
		assert(false, "trade player section given no trade routes to list")

	var first_trade_route: TradeRoute = trade_routes[0]
	var sending_id: int = first_trade_route.sending_player_id
	var receiving_id: int = first_trade_route.receiving_player_id
	var our_player_id: int = multiplayer.get_unique_id()

	var other_player_name: String
	if trade_direction == Types.TradeDirection.RECEIVING:
		other_player_name = ConnectionSystem.get_player(sending_id).name
	elif trade_direction == Types.TradeDirection.SENDING:
		other_player_name = ConnectionSystem.get_player(receiving_id).name

	trade_player_header.visible = true
	trade_player_header.update_trade_direction(trade_direction)
	trade_player_header.update_player(other_player_name)

	for trade_route: TradeRoute in trade_routes:
		var item: Types.Item = trade_route.item
		var amount: float = trade_route.amount
		var net_production: float = Model.get_item_change_rate(our_player_id, item)
		var trade_item_details: TradeItemDetails = trade_item_details_scene.instantiate()
		# TODO: trade details should display trade amount specified vs actual amount traded
		# when add_child happens, _ready code will run, which has to happen before updates
		details_list_container.add_child(trade_item_details)
		trade_item_details.update_item_icon(Items.get_info(item).icon)
		trade_item_details.update_item_production_text(amount, net_production)


func _ready() -> void:
	_remove_item_details()


## Remove all TradeItemDetails, leaving only the TradePlayerHeader.
func _remove_item_details() -> void:
	for child: Node in details_list_container.get_children():
		if child is TradeItemDetails:
			child.queue_free()

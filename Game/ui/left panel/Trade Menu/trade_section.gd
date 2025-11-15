class_name TradeSection
extends Control
## List of all items that either we are trading to someone else, or that we are receiving from other
## players.

var trade_player_section_scene: PackedScene = preload(
	"res://Game/ui/left panel/Trade Menu/trade_player_section.tscn"
)

@onready var trade_player_section_list: VBoxContainer = %TradePlayerSectionList
@onready var trade_section_header: Label = %TradeSectionHeader


## Given a list of trade routes that are all sending routes or all receiving routes, generate the
## appropriate TradePlayerSections and add them to the trade section list.
func update_section(trade_routes: Array, trade_direction: Types.TradeDirection) -> void:
	_remove_player_sections()

	if trade_direction == Types.TradeDirection.RECEIVING:
		trade_section_header.text = "Receiving"
	else:  # trade_direction == Types.TradeDirection.SENDING:
		trade_section_header.text = "Sending"

	# group trade routes together by what the other player involved is
	var trade_routes_by_other_player: Dictionary[int, Array]
	for trade_route: TradeRoute in trade_routes:
		var other_player_id: int
		if trade_direction == Types.TradeDirection.RECEIVING:
			other_player_id = trade_route.sending_player_id
		else:  # trade_direction == Types.TradeDirection.SENDING:
			other_player_id = trade_route.receiving_player_id

		var routes_with_other_player: Array = trade_routes_by_other_player.get_or_add(
			other_player_id, []
		)
		routes_with_other_player.append(trade_route)

	# create a trade player section for each unique player we are trading with
	for other_player_id: int in trade_routes_by_other_player.keys():
		var routes_with_other_player: Array = trade_routes_by_other_player[other_player_id]
		var trade_player_section: TradePlayerSection = trade_player_section_scene.instantiate()
		# when add_child happens, _ready code will run, which has to happen before update_section
		trade_player_section_list.add_child(trade_player_section)
		trade_player_section.update_section(routes_with_other_player, trade_direction)


func _ready() -> void:
	_remove_player_sections()


## Remove all TradePlayerSections, leaving only the TradeSectionHeader.
func _remove_player_sections() -> void:
	for child: Node in trade_player_section_list.get_children():
		if child is TradePlayerSection:
			child.queue_free()

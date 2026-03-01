class_name TradeMenuPanel
extends Control
## Menu that displays all trade information, as well as letting you add new trade routes.

var trade_routes: TradeModel

@onready var receiving_section: TradeSection = %ReceivingSection
@onready var sending_section: TradeSection = %SendingSection


func _ready() -> void:
	Model.game_ready.connect(_on_game_ready)
	trade_routes = Model.game_state.trade_routes


## Update the trade menu with the current trade information from TradeSystem.
func update() -> void:
	if visible:
		var our_player_id = multiplayer.get_unique_id()
		receiving_section.update_section(
			trade_routes.get_routes_received_by_player(our_player_id), Types.TradeDirection.RECEIVING
		)
		sending_section.update_section(
			trade_routes.get_routes_sent_by_player(our_player_id), Types.TradeDirection.SENDING
		)


func _on_game_ready() -> void:
	Model.tick_done.connect(update)
	update()

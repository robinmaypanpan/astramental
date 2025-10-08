extends MarginContainer

@export var item_type: Types.Item

var item_count: float = 0.0
var change: float = 0.0

@onready var icon := %Icon
@onready var count_text := %CountText


func _ready() -> void:
	var icon_to_use := Items.get_info(item_type).icon
	icon.texture = icon_to_use
	render_text()


## Given the new count, update the current item count to the new one.
func update_count(new_count: float) -> void:
	item_count = new_count
	render_text()


## Given the new change rate, update the current change rate.
func update_change_rate(new_change: float) -> void:
	change = new_change
	render_text()


# PRIVATE METHODS


## Internal function to render the text
func render_text() -> void:
	# TODO I18N: This format needs to be internationalized

	# truncates when doing float -> %d, which is the desired behavior
	count_text.text = "%d (%+d/s)" % [item_count, change]

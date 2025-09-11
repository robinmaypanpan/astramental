extends MarginContainer

@onready var _icon := %Icon
@onready var _count_text := %CountText

@export var item_type: Types.Item

var _item_count: float = 0.0

## Given the new count, update the current item count to the new one.
func update_count(new_count: float) -> void:
	var change = new_count - _item_count
	_item_count = new_count
	# truncates when doing float -> %d, which is the desired behavior
	_count_text.text = "%d (%+d/s)" % [_item_count, change]

func _ready() -> void:
	var icon_to_use = Items.get_info(item_type).icon
	_icon.texture = icon_to_use
	update_count(0.0)

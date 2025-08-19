extends MarginContainer


@onready var _ItemTypeSelect: OptionButton = %ItemTypeSelect
@onready var _AmountText: LineEdit = %AmountText

signal add_items(item_type: Item.Type, amount: int)

var amount: int:
	set(value):
		amount = value
		_update_amount_text()

func _ready() -> void:
	for item_type in Item.Type.values():
		var item_icon := Items.get_info(item_type).icon
		_ItemTypeSelect.add_icon_item(item_icon, "")
	amount = 1

func _update_amount_text() -> void:
	var old_caret_column := _AmountText.caret_column
	_AmountText.text = str(amount)
	_AmountText.caret_column = old_caret_column

func _on_minus_button_pressed() -> void:
	var new_amount := amount / 10
	if new_amount < 1:
		amount = 1
	else:
		amount = new_amount

func _on_plus_button_pressed() -> void:
	amount *= 10

func _on_amount_text_text_changed(new_text: String) -> void:
	if new_text:
		var interpreted_amount = int(new_text)
		if interpreted_amount != 0: # int() returns 0 if string isn't int
			amount = interpreted_amount


func _on_add_items_button_pressed() -> void:
	var item_type := _ItemTypeSelect.selected as Item.Type
	print("emitting add_items(%s, %s)" % [item_type, amount])
	add_items.emit(item_type, amount)

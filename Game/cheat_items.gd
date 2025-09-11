extends MarginContainer


@onready var _ItemTypeSelect: OptionButton = %ItemTypeSelect
@onready var _AmountText: LineEdit = %AmountText

## Emitted when the cheat items GUI tries to add items to the player
signal add_items(item_type: Types.Item, amount: int)

## The amount of items to add to the player, corresponds to the text in AmountText
var amount: int:
	set(value):
		amount = value
		_update_amount_text()

func _ready() -> void:
	for item_type in Types.Item.values():
		var item_icon := Items.get_info(item_type).icon
		_ItemTypeSelect.add_icon_item(item_icon, "")
	amount = 1

func _update_amount_text() -> void:
	# try and preserve the caret position when updating the amount
	var old_caret_column := _AmountText.caret_column
	_AmountText.text = str(amount)
	_AmountText.caret_column = old_caret_column

## Divide by 10 on minus button press
func _on_minus_button_pressed() -> void:
	var new_amount := amount / 10 # integer division is fine
	if new_amount < 1:
		amount = 1
	else:
		amount = new_amount

## multiply by 10 on plus button press
func _on_plus_button_pressed() -> void:
	amount *= 10

## When the amount text changes, update our internal amount count
func _on_amount_text_text_changed(new_text: String) -> void:
	if new_text:
		var interpreted_amount = int(new_text)
		if interpreted_amount != 0: # int() returns 0 if string isn't int
			amount = interpreted_amount


func _on_add_items_button_pressed() -> void:
	var item_type := _ItemTypeSelect.selected as Types.Item
	print("emitting add_items(%s, %s)" % [item_type, amount])
	add_items.emit(item_type, amount)

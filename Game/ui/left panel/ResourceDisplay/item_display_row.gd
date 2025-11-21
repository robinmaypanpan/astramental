class_name ItemDisplayRow
extends MarginContainer

## This is the item that should be displayed in this widget
@export var item_type: Types.Item

## This is the color that should be used whenever the storage is not full
@export var storage_good: Color = Color.GREEN

## this is the color that should be used when the storage is almost full
@export var storage_almost_full: Color = Color.YELLOW

## This is the color that should be used when storage is full
@export var storage_full: Color = Color.DARK_RED

## When the percentage is over this value, the "almost full" color is used
@export var almost_full_threshold: float = 0.8

## Shown when the value is increasing
@export var increasing_arrow: Texture

## Shown when the value is decreasing
@export var decreasing_arrow: Texture

## Shown when the value is not changing
@export var not_changing: Texture

## Shown when the value is blocked because storage is full
@export var storage_full_indicator: Texture

var item_count: float = 0.0
var change: float = 0.0
var storage_cap: float = 0.0

@onready var icon := %Icon
@onready var item_count_label: Label = %ItemCount
@onready var change_rate_label: Label = %ChangeRate
@onready var storage_bar: ProgressBar = %StorageBar
@onready var change_rate_indicator: TextureRect = %ChangeRateIndicator


func _ready() -> void:
	var icon_to_use := Items.get_info(item_type).icon
	icon.texture = icon_to_use
	name = "Item Display Row for %s" % Types.Item.keys()[item_type]
	update_view()


func _on_mouse_entered() -> void:
	Globals.update_tooltip_target(self)


func _on_mouse_exited() -> void:
	Globals.clear_tooltip_target(self)


## Returns the item type that this particular resource display row represents
func get_item_type() -> Types.Item:
	return item_type


## Given the new count, update the current item count to the new one.
func update_count(new_count: float) -> void:
	item_count = new_count
	update_view()


## Given the new change rate, update the current change rate.
func update_change_rate(new_change: float) -> void:
	change = new_change
	update_view()


## Given new storage cap, update the current storage cap.
func update_storage_cap(new_cap: float) -> void:
	storage_cap = new_cap
	update_view()


# PRIVATE METHODS


## Internal function to render the text
func update_view() -> void:
	update_storage_bar()

	# TODO I18N: This format needs to be internationalized
	# truncates when doing float -> %d, which is the desired behavior
	item_count_label.text = "%d" % [item_count]
	change_rate_label.text = "(%.1f/s)" % [abs(change)]

	if not is_zero_approx(change) and item_count >= storage_cap and storage_cap > 0.0:
		change_rate_indicator.texture = storage_full_indicator
	elif change > 0.0:
		change_rate_indicator.texture = increasing_arrow
	elif change < 0.0:
		change_rate_indicator.texture = decreasing_arrow
	else:
		change_rate_indicator.texture = not_changing


func update_storage_bar() -> void:
	var fill_style: StyleBox = storage_bar.get_theme_stylebox("fill").duplicate()
	if item_count >= storage_cap:
		# We are full
		storage_bar.value = 1.0

		fill_style.bg_color = storage_full
	else:
		var storage_value = item_count / storage_cap
		storage_bar.value = storage_value
		if storage_value >= almost_full_threshold:
			fill_style.bg_color = storage_almost_full
		else:
			fill_style.bg_color = storage_good

	storage_bar.remove_theme_stylebox_override("fill")
	storage_bar.add_theme_stylebox_override("fill", fill_style)

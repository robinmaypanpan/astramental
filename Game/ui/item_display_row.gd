extends MarginContainer

## This is the item that should be displayed in this widget
@export var item_type: Types.Item

## This is the color that should be used whenever the storage is not full
@export var storage_good: Color = Color.GREEN

## this is the color that should be used when the storage is almost full
@export var storage_almost_full: Color = Color.YELLOW

## This is the color that should be used when storage is full
@export var storage_full: Color = Color.DARK_RED

@export var almost_full_threshold: float = 80.0

var item_count: float = 0.0
var change: float = 0.0

@onready var icon := %Icon
@onready var count_text := %CountText
@onready var storage_bar: ProgressBar = %StorageBar


func _ready() -> void:
	var icon_to_use := Items.get_info(item_type).icon
	icon.texture = icon_to_use
	update_storage_bar()
	render_text()


## Given the new count, update the current item count to the new one.
func update_count(new_count: float) -> void:
	item_count = new_count	
	update_storage_bar()
	render_text()


## Given the new change rate, update the current change rate.
func update_change_rate(new_change: float) -> void:
	change = new_change
	render_text()
	
func update_storage_bar() -> void:
	var storage_limit: float = Model.get_storage_limit(multiplayer.get_unique_id(), item_type)
	
	print("Updating storage limit with %f/%f" % [item_count, storage_limit])
	
	var fill_style: StyleBox = storage_bar.get_theme_stylebox("fill").duplicate()
	if item_count >= storage_limit:
		# We are full
		storage_bar.value = 1.0
				
		fill_style.bg_color = storage_full

	else:
		var storage_value = item_count / storage_limit
		storage_bar.value = storage_value
		if storage_value >= almost_full_threshold:
			fill_style.bg_color = storage_almost_full
		else:
			fill_style.bg_color = storage_good

	storage_bar.remove_theme_stylebox_override("fill")
	storage_bar.add_theme_stylebox_override("fill", fill_style)
# PRIVATE METHODS


## Internal function to render the text
func render_text() -> void:
	# TODO I18N: This format needs to be internationalized

	# truncates when doing float -> %d, which is the desired behavior
	count_text.text = "%d (%+.1f/s)" % [item_count, change]

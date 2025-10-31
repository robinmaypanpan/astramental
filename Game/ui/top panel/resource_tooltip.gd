class_name ResourceTooltip
extends Tooltip

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

## Shown the the value is not changing
@export var not_changing: Texture

# General elements
@onready var resource_icon_texture: TextureRect = %ResourceIcon
@onready var resource_name_label: Label = %ResourceName
@onready var description_label: Label = %Description

# Storage
@onready var storage_quantity_label: Label = %StorageQuantity
@onready var storage_bar: ProgressBar = %StorageBar

# Production Info
@onready var consumption_quantity_label: Label = %ConsumptionQuantity
@onready var consumption_type_icon: TextureRect = %ConsumptionTypeIcon
@onready var production_quantity_label: Label = %ProductionQuantity
@onready var production_type_icon: TextureRect = %ProductionTypeIcon
@onready var net_quantity_label: Label = %NetQuantity
@onready var net_type_icon: TextureRect = %NetTypeIcon
@onready var net_change_rate_indicator_icon: TextureRect = %ChangeRateIndicator


func set_tooltip_source(node: Control) -> void:
	assert(
		node is ItemDisplayRow,
		"ResourceTooltip can only accept ItemDisplayRow nodes as tooltip sources"
	)
	var item_row: ItemDisplayRow = node as ItemDisplayRow
	var item_type: Types.Item = item_row.get_item_type()

	var storage_info: ItemStorageInfo = Model.get_item_storage_info(item_type)
	var item_resource: ItemResource = Items.get_info(item_type)

	# Set icon texture
	resource_icon_texture.texture = item_resource.icon
	production_type_icon.texture = item_resource.icon
	consumption_type_icon.texture = item_resource.icon
	net_type_icon.texture = item_resource.icon

	# Set basic resource info
	resource_name_label.text = item_resource.display_name
	description_label.text = item_resource.description

	# Set storage info
	update_storage(storage_info)

	consumption_quantity_label.text = "%0.1f" % storage_info.consumption
	production_quantity_label.text = "%0.1f" % storage_info.production

	var net_change: float = storage_info.get_net_change()
	net_quantity_label.text = "%+0.1f" % net_change
	# Update net change rate indicator
	if net_change > 0:
		net_change_rate_indicator_icon.texture = increasing_arrow
	elif net_change < 0:
		net_change_rate_indicator_icon.texture = decreasing_arrow
	else:
		net_change_rate_indicator_icon.texture = not_changing


func update_storage(storage_info: ItemStorageInfo) -> void:
	storage_quantity_label.text = (
		"%d / %d" % [storage_info.current_quantity, storage_info.storage_cap]
	)
	var fill_style: StyleBox = storage_bar.get_theme_stylebox("fill").duplicate()
	if storage_info.current_quantity >= storage_info.storage_cap:
		# We are full
		storage_bar.value = 1.0

		fill_style.bg_color = storage_full
	else:
		var storage_value: float = storage_info.get_capacity_percentage()
		storage_bar.value = storage_value
		if storage_value >= almost_full_threshold:
			fill_style.bg_color = storage_almost_full
		else:
			fill_style.bg_color = storage_good

	storage_bar.remove_theme_stylebox_override("fill")
	storage_bar.add_theme_stylebox_override("fill", fill_style)

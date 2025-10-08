extends Node

var settings: SettingsResource

func _ready() -> void:
    settings = preload("Game/data/settings.tres")
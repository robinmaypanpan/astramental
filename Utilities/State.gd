class_name State
extends Node

signal finished(next_state: String, flags: Dictionary)


func enter(old_state: String, flags: Dictionary):
	pass


func exit(new_state: String, flags: Dictionary):
	pass


func update(delta: float):
	pass


func physics_update(delta: float):
	pass


func handle_input(event: InputEvent):
	pass

extends Control

@onready var debug_layer = $".."

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug") and not event.is_echo():
		debug_layer.visible = not debug_layer.visible

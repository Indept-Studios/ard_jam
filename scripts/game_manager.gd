extends Node

@onready var game_over_root = %GameOverRoot

var is_paused:bool = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _on_enemy_game_over():
	get_tree().paused = true
	game_over_root.visible = true


func _on_restart_button_pressed():
	get_tree().paused = false
	game_over_root.visible = false
	get_tree().reload_current_scene()

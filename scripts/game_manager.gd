extends Node

var is_paused:bool = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _on_enemy_game_over():
	get_tree().paused = true

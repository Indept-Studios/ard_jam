extends Node

@onready var timer = $"../Timer"
@onready var game_over_root = %GameOverRoot
@onready var highscore_label = %HighscoreLabel

var highscore: int = 0
var is_paused:bool = false

func _ready():
	timer.start(1)
	highscore_label.text = str(highscore)

func _on_enemy_game_over():
	get_tree().paused = true
	timer.stop()
	game_over_root.visible = true

func _on_restart_button_pressed():
	get_tree().paused = false
	game_over_root.visible = false
	get_tree().reload_current_scene()

func _on_timer_timeout():
	highscore += 1
	highscore_label.text = str(highscore)
	timer.start(1)

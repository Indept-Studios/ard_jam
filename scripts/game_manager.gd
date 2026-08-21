extends Node

@onready var timer = %Timer
@onready var game_over_root = %GameOverRoot
@onready var highscore_label = %HighscoreLabel
@onready var pause_root = %PauseRoot
@onready var collectable_spawner = %CollectableSpawner

const COLLECTABLE = preload("uid://df1b2gd4xli0d")

var spawners: Array[Marker2D]
var occupied_spawners: Array[Marker2D] = []
var highscore: int = 0
var max_collectables: int = 2
var collectable_count: int = 0

func _ready():
	timer.start(1)
	highscore_label.text = str(highscore)
	for child in collectable_spawner.get_children():
		if child is Node2D:
			spawners.append(child)
	_pick_spawner()

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

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

func toggle_pause():
	pause_root.visible = !pause_root.visible
	get_tree().paused = !get_tree().paused

func _on_resume_button_pressed():
	toggle_pause()

func _on_quit_button_pressed():
	get_tree().quit()

func _pick_spawner():
	while collectable_count < max_collectables:
		var free_spawners: Array[Node] = []

		for spawner in spawners:
			if spawner not in occupied_spawners:
				free_spawners.append(spawner)

		if free_spawners.is_empty():
			return

		var selected_spawner = free_spawners.pick_random()
		occupied_spawners.append(selected_spawner)
		_spawn(selected_spawner)
	
func _spawn(spawner: Node2D) -> void:
	var collectable = COLLECTABLE.instantiate()

	collectable.collected.connect(func():
		_on_collectable_collected(spawner)
	)
	%CollectableRoot.add_child(collectable)
	collectable.global_position = spawner.global_position
	collectable.name = "collectable_" + str(collectable_count)
	collectable_count += 1

func _on_collectable_collected(spawner: Node2D) -> void:
	collectable_count -= 1
	occupied_spawners.erase(spawner)
	_pick_spawner.call_deferred()

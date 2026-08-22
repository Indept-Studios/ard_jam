extends Node

@onready var timer = %Timer
@onready var spawn_timer = %SpawnTimer
@onready var player: CharacterBody2D = %Player
@onready var game_over_root = %GameOverRoot
@onready var highscore_label = %HighscoreLabel
@onready var pause_root = %PauseRoot
@onready var collectable_spawner = %CollectableSpawner
@onready var enemy_spawner = %EnemySpawner
@onready var enemy_root = %EnemyRoot

const COLLECTABLE = preload("uid://df1b2gd4xli0d")
const ENEMY = preload("uid://deet1vbsx6s3x")
const SPIRIT_KILL_RADIUS := 35.0

var pickup_spawners: Array[Marker2D]
var occupied_collectable_spawners: Array[Marker2D] = []
var enemy_spawners: Array[Marker2D]
var max_collectables: int = 2
var collectable_count: int = 0

var player_mode = PlayerMode.NORMAL
var time_since_last_collectable := 0.0

var highscore: int = 0
var is_game_over := false

var next_wave_at: int = 30
var enemy_count: int = 0

enum PlayerMode {
	NORMAL,
	SPIRIT
}

func _ready():
	timer.start(1)
	spawn_timer.start(4.0)
	highscore_label.text = str(highscore)
	for child in collectable_spawner.get_children():
		if child is Marker2D:
			pickup_spawners.append(child)
	for child in enemy_spawner.get_children():
		if child is Marker2D:
			enemy_spawners.append(child)
	_pick_spawner()
	_spawn_enemies(2,2)

func _process(_delta):
	if is_game_over:
		return

	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func _physics_process(_delta: float) -> void:
	if player_mode != PlayerMode.SPIRIT:
		return
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy.global_position.distance_to(player.global_position) <= SPIRIT_KILL_RADIUS:
			enemy.queue_free()
			
func _on_restart_button_pressed():
	get_tree().paused = false
	game_over_root.visible = false
	get_tree().reload_current_scene()

func _on_timer_timeout():
	highscore += 1
	highscore_label.text = str(highscore)
	time_since_last_collectable += 1

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

		for spawner in pickup_spawners:
			if spawner not in occupied_collectable_spawners:
				free_spawners.append(spawner)

		if free_spawners.is_empty():
			return

		var selected_spawner = free_spawners.pick_random()
		occupied_collectable_spawners.append(selected_spawner)
		_spawn_collectable(selected_spawner)
	
func _spawn_collectable(spawner: Node2D) -> void:
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
	occupied_collectable_spawners.erase(spawner)
	_pick_spawner.call_deferred()
	time_since_last_collectable = 0

func _on_enemy_hit(enemy: CharacterBody2D):
	if player_mode == PlayerMode.SPIRIT:
		enemy.queue_free()
		return
	
	if time_since_last_collectable >= 10.0:
		start_sprite_mode()
	else:
		is_game_over = true
		get_tree().paused = true
		timer.stop()
		spawn_timer.stop()
		game_over_root.visible = true

func start_sprite_mode():
	player_mode = PlayerMode.SPIRIT
	player.set_spirit_mode(true)
	var sprite_timer = Timer.new()
	sprite_timer.one_shot = true
	sprite_timer.timeout.connect(_on_sprite_timer_timeout)
	sprite_timer.timeout.connect(sprite_timer.queue_free)
	add_child(sprite_timer)
	sprite_timer.start(10)
	
func _on_sprite_timer_timeout():
	player_mode = PlayerMode.NORMAL
	player.set_spirit_mode(false)
	time_since_last_collectable = 0

func _on_spawn_timer_timeout() -> void:
	var spawn_interval: float
	var enemy_limit: int

	if highscore > 45:
		spawn_interval = 2.0
		enemy_limit = 7
	elif highscore > 20:
		spawn_interval = 3.0
		enemy_limit = 5
	else:
		spawn_interval = 4.0
		enemy_limit = 3

	_spawn_enemies(1, enemy_limit)

	if highscore >= next_wave_at:
		_spawn_enemies(2, enemy_limit)
		next_wave_at += 15

	spawn_timer.start(spawn_interval)

func _spawn_enemies(amount: int, enemy_limit: int) -> void:
	var active_enemy_count := get_tree().get_nodes_in_group("Enemies").size()
	var available_slots := enemy_limit - active_enemy_count
	if available_slots <= 0:
		return
	var spawn_count: int = amount
	if spawn_count > available_slots:
		spawn_count = available_slots

	for _index in spawn_count:
		_spawn_enemy(enemy_spawners.pick_random())

func _spawn_enemy(spawner: Marker2D) -> void:
	var enemy: CharacterBody2D = ENEMY.instantiate()
	enemy.player = player
	enemy.enemy_hit.connect(_on_enemy_hit)
	enemy.add_to_group("Enemies")
	enemy_root.add_child(enemy)
	enemy.global_position = spawner.global_position
	enemy.name = "Enemy_" + str(enemy_count)
	enemy_count += 1

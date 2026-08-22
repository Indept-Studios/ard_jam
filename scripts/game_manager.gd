extends Node

@export var collectable_definitions: Array[CollectableDefinition] = []

@onready var timer = %Timer
@onready var spawn_timer = %SpawnTimer
@onready var player: CharacterBody2D = %Player
@onready var game_over_root = %GameOverRoot
@onready var highscore_label = %HighscoreLabel
@onready var pause_root = %PauseRoot
@onready var collectable_spawner = %CollectableSpawner
@onready var enemy_spawner = %EnemySpawner
@onready var enemy_root = %EnemyRoot
@onready var score_label = %ScoreLabel

const COLLECTABLE = preload("uid://df1b2gd4xli0d")
const ENEMY = preload("uid://deet1vbsx6s3x")
const SPIRIT_BOMB = preload("res://scenes/spirit_bomb.tscn")
const SPIRIT_TARGET = preload("res://resources/spirit_target.tres")
const SPIRIT_KILL_RADIUS := 35.0
const SPIRIT_READY_AFTER := 10.0
const SPIRIT_TRANSFORM_DURATION := 6.0
const SPIRIT_TRANSFORM_START_AFTER := SPIRIT_READY_AFTER - SPIRIT_TRANSFORM_DURATION
const SPIRIT_TARGET_DURATION := 6.0
const SPIRIT_TARGET_SCORE := 5
const SPIRIT_BOMB_KILL_SCORE := 4

var pickup_spawners: Array[Marker2D]
var occupied_collectable_spawners: Array[Marker2D] = []
var enemy_spawners: Array[Marker2D]
var max_collectables: int = 2
var collectable_count: int = 0

var player_mode = PlayerMode.NORMAL
var time_since_last_collectable := 0.0
var is_transforming := false
var spirit_target_active := false
var spirit_target_collectable: Collectable
var spirit_target_spawner: Marker2D
var spirit_chain := 0
var spirit_timer: Timer

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
	spirit_timer = Timer.new()
	spirit_timer.one_shot = true
	spirit_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	spirit_timer.timeout.connect(_on_spirit_timer_timeout)
	add_child(spirit_timer)
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
	if spirit_target_active and is_instance_valid(spirit_target_collectable):
		spirit_target_collectable.set_countdown(spirit_timer.time_left)
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func _physics_process(_delta: float) -> void:
	if player_mode != PlayerMode.SPIRIT:
		return
	for enemy_node in get_tree().get_nodes_in_group("Enemies"):
		var enemy: CharacterBody2D = enemy_node as CharacterBody2D
		if enemy == null:
			continue

		var distance: float = enemy.global_position.distance_to(player.global_position)
		if distance <= SPIRIT_KILL_RADIUS:
			_destroy_spirit_enemy(enemy)
			
func _on_restart_button_pressed():
	get_tree().paused = false
	game_over_root.visible = false
	get_tree().reload_current_scene()

func _on_timer_timeout():
	highscore += 1
	highscore_label.text = str(highscore)
	time_since_last_collectable += 1
	if player_mode == PlayerMode.NORMAL:
		if not is_transforming and time_since_last_collectable >= SPIRIT_TRANSFORM_START_AFTER:
			is_transforming = true
			player.start_spirit_transformation()

		if time_since_last_collectable >= SPIRIT_READY_AFTER:
			start_spirit_mode()

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
	var definition: CollectableDefinition = collectable_definitions.pick_random()

	collectable.collected.connect(func(collected_definition: CollectableDefinition):
		_on_collectable_collected(spawner, collected_definition)
	)
	%CollectableRoot.add_child(collectable)
	collectable.setup(definition)
	collectable.global_position = spawner.global_position
	collectable.name = "collectable_" + str(collectable_count)
	collectable_count += 1

func _on_collectable_collected(spawner: Node2D, definition: CollectableDefinition) -> void:
	collectable_count -= 1
	occupied_collectable_spawners.erase(spawner)
	_pick_spawner.call_deferred()
	time_since_last_collectable = 0
	if is_transforming:
		is_transforming = false
		player.set_spirit_mode(false)
	if player_mode == PlayerMode.SPIRIT:
		_end_spirit_mode()

	_apply_effect(definition)

func _apply_effect(definition):
	if definition.effect_type == CollectableDefinition.EffectType.SPEED:
		player.set_modifier(definition)
	elif definition.effect_type == CollectableDefinition.EffectType.EXPLOSION:
		_start_spirit_bomb(definition)
	elif definition.effect_type == CollectableDefinition.EffectType.INVULNERABLE:
		player.set_modifier(definition)

func _start_spirit_bomb(definition: CollectableDefinition) -> void:
	var bomb = SPIRIT_BOMB.instantiate()
	bomb.enemies_destroyed.connect(_on_spirit_bomb_enemies_destroyed)
	player.add_child(bomb)
	bomb.position = Vector2.ZERO
	bomb.setup(definition)

func _on_spirit_bomb_enemies_destroyed(amount: int) -> void:
	highscore += amount * SPIRIT_BOMB_KILL_SCORE
	highscore_label.text = str(highscore)
		
func _on_enemy_hit(enemy: CharacterBody2D):
	if player_mode == PlayerMode.SPIRIT:
		_destroy_spirit_enemy(enemy)
		return
	if player.is_invulnerable:
		enemy.queue_free()
		return
		
	_game_over()

func start_spirit_mode() -> void:
	is_transforming = false
	player_mode = PlayerMode.SPIRIT
	player.set_spirit_mode(true)

func _destroy_spirit_enemy(enemy: CharacterBody2D) -> void:
	if not is_instance_valid(enemy):
		return

	enemy.queue_free()

	if not spirit_target_active:
		spirit_target_active = true
		_start_spirit_challenge.call_deferred()

func _start_spirit_challenge() -> void:
	if player_mode != PlayerMode.SPIRIT or not spirit_target_active:
		return

	spirit_timer.start(SPIRIT_TARGET_DURATION)
	_spawn_spirit_target()

func _spawn_spirit_target() -> void:
	var free_spawners: Array[Marker2D] = []

	for spawner in pickup_spawners:
		if spawner not in occupied_collectable_spawners:
			free_spawners.append(spawner)

	if free_spawners.is_empty():
		push_error("GameManager: Kein freier Spawnpunkt fuer das Spirit-Ziel.")
		return

	spirit_target_spawner = free_spawners.pick_random()
	occupied_collectable_spawners.append(spirit_target_spawner)

	var collectable := COLLECTABLE.instantiate() as Collectable
	collectable.collected.connect(func(_definition: CollectableDefinition):
		_on_spirit_target_collected()
	)
	%CollectableRoot.add_child(collectable)
	collectable.setup(SPIRIT_TARGET)
	collectable.global_position = spirit_target_spawner.global_position
	collectable.name = "SpiritTarget"
	spirit_target_collectable = collectable
	spirit_target_collectable.set_countdown(spirit_timer.time_left)

func _on_spirit_target_collected() -> void:
	if spirit_target_spawner:
		occupied_collectable_spawners.erase(spirit_target_spawner)

	spirit_target_collectable = null
	spirit_target_spawner = null
	spirit_chain += 1
	highscore += SPIRIT_TARGET_SCORE * spirit_chain
	highscore_label.text = str(highscore)
	spirit_timer.start(SPIRIT_TARGET_DURATION)
	_spawn_spirit_target.call_deferred()

func _on_spirit_timer_timeout() -> void:
	if is_instance_valid(spirit_target_collectable):
		spirit_target_collectable.visible = false
	_game_over()

func _end_spirit_mode() -> void:
	player_mode = PlayerMode.NORMAL
	player.set_spirit_mode(false)
	spirit_timer.stop()
	spirit_target_active = false
	spirit_chain = 0

	if is_instance_valid(spirit_target_collectable):
		spirit_target_collectable.queue_free()
	if spirit_target_spawner:
		occupied_collectable_spawners.erase(spirit_target_spawner)

	spirit_target_collectable = null
	spirit_target_spawner = null

func _game_over() -> void:
	is_game_over = true
	get_tree().paused = true
	timer.stop()
	spawn_timer.stop()
	spirit_timer.stop()
	score_label.text = str("SCORE: ", highscore)
	game_over_root.visible = true
	
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

extends Node2D

signal enemies_destroyed(amount: int)

@onready var detonation_timer: Timer = $DetonationTimer
@onready var explosion_particles: GPUParticles2D = $ExplosionParticles

var definition: CollectableDefinition
var current_radius := 0.0
var has_detonated := false

func _ready() -> void:
	detonation_timer.one_shot = true
	detonation_timer.timeout.connect(_on_detonation_timer_timeout)
	
func setup(new_definition: CollectableDefinition) -> void:
	definition = new_definition
	current_radius = 0.0
	detonation_timer.start(definition.duration)
	queue_redraw()

func _process(_delta: float) -> void:
	if not definition or detonation_timer.is_stopped():
		return

	var progress := 1.0 - detonation_timer.time_left / definition.duration
	current_radius = definition.radius * progress
	queue_redraw()

func _on_detonation_timer_timeout() -> void:
	current_radius = definition.radius
	queue_redraw()
	explosion_particles.restart()
	explosion_particles.emitting = true
	var killed_enemy_count := 0
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var enemy_2d := enemy as Node2D
		if enemy_2d == null:
			continue
		var distance: float = enemy_2d.global_position.distance_to(global_position)
		if distance <= definition.radius:
			if enemy_2d.has_method("destroy"):
				enemy_2d.destroy()
			else:
				enemy_2d.queue_free()
			killed_enemy_count += 1
	if killed_enemy_count > 0:
		enemies_destroyed.emit(killed_enemy_count)
	has_detonated = true
	queue_redraw()
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _draw() -> void:
	if not definition:
		return
	draw_circle(
		Vector2.ZERO,
		current_radius,
		Color(definition.color, 0.2)
	)
	if has_detonated:
		draw_circle(
			Vector2.ZERO,
			definition.radius,
			Color(definition.color, 0.6)
		)
	draw_arc(
		Vector2.ZERO,
		current_radius,
		0.0,
		TAU,
		48,
		definition.color,
		2.0
	)

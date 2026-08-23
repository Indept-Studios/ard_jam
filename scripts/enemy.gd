extends CharacterBody2D

signal enemy_hit

const ENEMY_DEATH_EFFECT = preload("res://scenes/enemy_death_effect.tscn")

@onready var sprite: Sprite2D = $Sprite2D

@export var player: CharacterBody2D 
@export var separation_radius := 45.0
@export var separation_strength := 180.0

var speed: float = 150.0
var is_destroyed := false
var hover_time := randf() * TAU
var base_sprite_position := Vector2.ZERO

func _ready() -> void:
	base_sprite_position = sprite.position

func _process(delta: float) -> void:
	hover_time += delta
	var bob_offset := sin(hover_time * 4.0) * 3.0
	var wobble := sin(hover_time * 6.0) * 0.04
	sprite.position = base_sprite_position + Vector2(0, bob_offset)
	sprite.scale = Vector2(1.0 + wobble, 1.0 - wobble)

func _physics_process(_delta) -> void:
	if not player:
		return
	var direction_to_player = global_position.direction_to(player.global_position)
	var separation = Vector2.ZERO

	for other_enemy in get_tree().get_nodes_in_group("Enemies"):
		if other_enemy == self:
			continue
		var offset = global_position - other_enemy.global_position
		var distance = offset.length()
		if distance > 0.0 and distance < separation_radius:
			var strength = 1.0 - (distance / separation_radius)
			separation += offset.normalized() * strength

	velocity = direction_to_player * speed
	velocity += separation * separation_strength
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		enemy_hit.emit(self)

func destroy() -> void:
	if is_destroyed:
		return

	is_destroyed = true
	var death_effect := ENEMY_DEATH_EFFECT.instantiate() as GPUParticles2D
	get_tree().current_scene.add_child(death_effect)
	death_effect.global_position = global_position
	queue_free()

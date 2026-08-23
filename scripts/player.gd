extends CharacterBody2D

const SPEED_SOUND = preload("res://sounds/speed.wav")
const SHIELD_SOUND = preload("res://sounds/shild.wav")

@onready var screen_size = get_viewport_rect().size
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var speed_particles: GPUParticles2D = $SpeedParticles
@onready var shield_particles: GPUParticles2D = $ShieldParticles
@onready var spirit_particles: GPUParticles2D = $SpiritParticles

var speed: float = 150.0
var speed_modifier: float = 1.0
var speed_timer: Timer
var is_invulnerable := false
var shield_timer: Timer
var hover_time := 0.0
var base_sprite_position := Vector2.ZERO
var effect_sound: AudioStreamPlayer

func _ready() -> void:
	base_sprite_position = animated_sprite.position
	effect_sound = AudioStreamPlayer.new()
	effect_sound.volume_db = -6.0
	add_child(effect_sound)
	speed_timer = Timer.new()
	speed_timer.one_shot = true
	speed_timer.timeout.connect(_on_speedtimer_timeout)
	add_child(speed_timer)
	shield_timer = Timer.new()
	shield_timer.one_shot = true
	shield_timer.timeout.connect(_on_shield_timer_timeout)
	add_child(shield_timer)
	animated_sprite.play("normal")

func _process(delta: float) -> void:
	hover_time += delta
	var bob_offset := sin(hover_time * 3.0) * 1.5
	var wobble := sin(hover_time * 4.5) * 0.015
	animated_sprite.position = base_sprite_position + Vector2(0, bob_offset)
	animated_sprite.scale = Vector2(1.0 + wobble, 1.0 - wobble)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * (speed * speed_modifier)

func _physics_process(_delta):
	get_input()
	if velocity.x != 0.0:
		animated_sprite.flip_h = velocity.x < 0.0
	move_and_slide()
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	speed_particles.emitting = speed_modifier > 1.0 and velocity.length() > 0.0
	shield_particles.emitting = is_invulnerable

func set_spirit_mode(enabled: bool) -> void:
	if enabled:
		animated_sprite.play("spirit")
		spirit_particles.emitting = true
		set_collision_mask_value(4, false)
	else:
		animated_sprite.play("normal")
		spirit_particles.emitting = false
		set_collision_mask_value(4, true)

func start_spirit_transformation() -> void:
	animated_sprite.play("transform_to_spirit")
	
func set_modifier(definition: CollectableDefinition) -> void:
	if definition.effect_type == CollectableDefinition.EffectType.SPEED:
		speed_modifier = definition.strength
		speed_timer.start(speed_timer.time_left + definition.duration)
		effect_sound.stream = SPEED_SOUND
		effect_sound.play()
		queue_redraw()
	elif definition.effect_type == CollectableDefinition.EffectType.INVULNERABLE:
		is_invulnerable = true
		shield_timer.start(shield_timer.time_left + definition.duration)
		effect_sound.stream = SHIELD_SOUND
		effect_sound.play()
		queue_redraw()

func _on_speedtimer_timeout():
	speed_modifier = 1.0
	queue_redraw()
	
func _on_shield_timer_timeout() -> void:
	is_invulnerable = false
	queue_redraw()

func _draw() -> void:
	if is_invulnerable:
		draw_arc(
			Vector2.ZERO,
			28.0,
			0.0,
			TAU,
			48,
			Color(0.25, 0.88, 0.63, 1.0),
			3.0
		)
	if speed_modifier > 1.0:
		draw_arc(
			Vector2.ZERO,
			21.0,
			0.0,
			TAU,
			48,
			Color(1.0, 0.82, 0.25, 1.0),
			2.0
		)

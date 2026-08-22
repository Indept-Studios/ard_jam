extends CharacterBody2D

@onready var screen_size = get_viewport_rect().size
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var normal_texture: Texture2D
@export var spirit_texture: Texture2D

var speed: float = 200.0
var speed_modifier: float = 1.0
var speed_timer: Timer
var is_invulnerable := false
var shield_timer: Timer

func _ready() -> void:
	speed_timer = Timer.new()
	speed_timer.one_shot = true
	speed_timer.timeout.connect(_on_speedtimer_timeout)
	add_child(speed_timer)
	shield_timer = Timer.new()
	shield_timer.one_shot = true
	shield_timer.timeout.connect(_on_shield_timer_timeout)
	add_child(shield_timer)
	animated_sprite.play("normal")

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * (speed * speed_modifier)

func _physics_process(delta):
	get_input()
	move_and_slide()
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func set_spirit_mode(enabled: bool) -> void:
	if enabled:
		animated_sprite.play("spirit")
		set_collision_mask_value(4, false)
	else:
		animated_sprite.play("normal")
		set_collision_mask_value(4, true)

func start_spirit_transformation() -> void:
	animated_sprite.play("transform_to_spirit")
	
func set_modifier(definition: CollectableDefinition) -> void:
	if definition.effect_type == CollectableDefinition.EffectType.SPEED:
		var previous_speed_modifier := speed_modifier
		speed_modifier = definition.strength
		speed_timer.start(speed_timer.time_left + definition.duration)
		queue_redraw()
	elif definition.effect_type == CollectableDefinition.EffectType.INVULNERABLE:
		is_invulnerable = true
		shield_timer.start(shield_timer.time_left + definition.duration)
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

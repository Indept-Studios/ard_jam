extends CharacterBody2D

@onready var screen_size = get_viewport_rect().size
@onready var color_rect: ColorRect = $ColorRect

var speed: float = 200.0
var speed_modifier: float = 1.0

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * (speed * speed_modifier)

func _physics_process(delta):
	get_input()
	move_and_slide()
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
func _on_collectable_collected():
	pass ## bring in modifier

func set_spirit_mode(enabled: bool) -> void:
	if enabled:
		color_rect.color = Color.MEDIUM_PURPLE
		set_collision_mask_value(4, false)
	else:
		color_rect.color = Color.BLUE
		set_collision_mask_value(4, true)

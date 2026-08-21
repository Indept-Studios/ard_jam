extends CharacterBody2D

signal game_over

@export var player: CharacterBody2D 

var speed: float = 150.0

func _ready():
	if not player:
		push_error("enemy.gd: on ", self.name, ", no player is set")

func _physics_process(delta) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_area_2d_body_entered(body):
	game_over.emit()

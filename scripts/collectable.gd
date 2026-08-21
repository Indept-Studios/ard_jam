extends Area2D

signal collected

@export var radius: float = 15

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.ORANGE)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collected.emit()
		queue_free()

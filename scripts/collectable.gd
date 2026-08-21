extends Area2D

signal collected

@export var radius: float = 15

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.ORANGE)

func _on_body_entered(body):
	collected.emit()
	queue_free()

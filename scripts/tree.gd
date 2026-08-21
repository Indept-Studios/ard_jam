extends StaticBody2D

@export var radius: float = 20

func _draw():
	draw_circle(Vector2.ZERO, radius, Color.DARK_GREEN)

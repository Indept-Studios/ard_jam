extends StaticBody2D

@export var radius: float = 20

func _draw():
	draw_circle(position.normalized(), radius, Color.DARK_GREEN)

extends Area2D

signal collected(definition: CollectableDefinition)

@export var radius: float = 15

var definition: CollectableDefinition

func setup(new_definition: CollectableDefinition) -> void:
	definition = new_definition
	queue_redraw()

func _draw() -> void:
	if definition:
		draw_circle(Vector2.ZERO, radius, definition.color)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collected.emit(definition)
		queue_free()

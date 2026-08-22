class_name Collectable extends Area2D

signal collected(definition: CollectableDefinition)

@export var radius: float = 15

@onready var countdown_label: Label = $CountdownLabel

var definition: CollectableDefinition

func setup(new_definition: CollectableDefinition) -> void:
	definition = new_definition
	$Sprite2D.texture = definition.texture
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collected.emit(definition)
		queue_free()

func set_countdown(seconds_left: float) -> void:
	countdown_label.visible = true
	countdown_label.text = str(ceili(seconds_left))

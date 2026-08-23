extends GPUParticles2D

func _ready() -> void:
	restart()
	emitting = true
	finished.connect(queue_free)

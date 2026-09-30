extends Node2D

@export var duration: float = 0.12
@export var end_scale: float = 1.18

func _ready() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE * end_scale, duration).from(Vector2(0.65, 0.65))
	tween.tween_property(self, "rotation", 0.22, duration).from(-0.18)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.finished.connect(queue_free)

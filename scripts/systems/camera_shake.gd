extends Camera2D

var _shake_tween: Tween
var _base_offset: Vector2

func shake(duration: float = 0.4, strength: float = 5.0) -> void:
	if _shake_tween and _shake_tween.is_running():
		_shake_tween.kill()
		offset = _base_offset

	_base_offset = offset
	var safe_duration := maxf(duration, 0.01)
	var steps := maxi(1, ceili(safe_duration / 0.04))
	var step_duration := safe_duration / float(steps)
	_shake_tween = create_tween()

	for step in range(1, steps + 1):
		var intensity := 1.0 - float(step) / float(steps)
		var displacement := Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		) * intensity
		_shake_tween.tween_property(self, "offset", _base_offset + displacement, step_duration)

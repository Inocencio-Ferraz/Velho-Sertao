extends Area2D

const MELEE_IMPACT_SCENE: PackedScene = preload("res://scenes/vfx/melee_impact.tscn")

func take_damage(amount: int) -> void:
	var enemy := get_parent()
	if amount <= 0 or bool(enemy.get("is_dead")) or not enemy.has_method("take_damage"):
		return

	enemy.call("take_damage", amount)
	var impact := MELEE_IMPACT_SCENE.instantiate() as Node2D
	enemy.add_child(impact)

extends Area2D

func take_damage(amount: int) -> void:
	var enemy := get_parent()
	if enemy.has_method("take_damage"):
		enemy.call("take_damage", amount)

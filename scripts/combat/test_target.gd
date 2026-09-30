extends Area2D

@export var max_health: int = 30

var health: int = 30
var _flash_tween: Tween

@onready var visual: Polygon2D = $Visual
@onready var health_label: Label = $HealthLabel

func _ready() -> void:
	health = maxi(1, max_health)
	_update_health_label()

func take_damage(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return

	health = maxi(0, health - amount)
	_update_health_label()
	_show_hit_feedback()
	print("Alvo de TESTE recebeu dano: ", amount, " | vida: ", health)

	if health == 0:
		print("Alvo de TESTE derrotado.")
		queue_free()

func _update_health_label() -> void:
	health_label.text = str(health)

func _show_hit_feedback() -> void:
	if _flash_tween and _flash_tween.is_running():
		_flash_tween.kill()
	visual.color = Color(1.0, 0.48, 0.25, 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(visual, "color", Color(0.9, 0.2, 0.18, 1.0), 0.18)

extends Area2D

@export var damage: int = 10
@export var attack_length: float = 42.0
@export var attack_width: float = 36.0
@export var active_duration: float = 0.12
@export var cooldown: float = 0.4
@export var player_radius: float = 10.0

@onready var hit_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_visual: Polygon2D = $AttackVisual

var facing_direction: Vector2 = Vector2.DOWN
var can_attack: bool = true
var attack_is_active: bool = false
var hit_targets: Array[Area2D] = []

func _ready() -> void:
	var rectangle := hit_shape.shape as RectangleShape2D
	rectangle.size = Vector2(attack_width, attack_length)
	attack_visual.polygon = PackedVector2Array([
		Vector2(-attack_width / 2.0, -attack_length / 2.0),
		Vector2(attack_width / 2.0, -attack_length / 2.0),
		Vector2(attack_width / 2.0, attack_length / 2.0),
		Vector2(-attack_width / 2.0, attack_length / 2.0)
	])
	hit_shape.disabled = true
	attack_visual.visible = false
	area_entered.connect(_on_area_entered)
	_update_position()

func set_facing_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		facing_direction = direction
		_update_position()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("melee_attack"):
		_try_attack()

func _try_attack() -> void:
	if not can_attack or bool(get_parent().get("is_dead")) or bool(get_parent().get("controls_locked")):
		return

	can_attack = false
	attack_is_active = true
	hit_targets.clear()
	attack_visual.visible = true
	hit_shape.set_deferred("disabled", false)
	get_tree().create_timer(cooldown).timeout.connect(_on_cooldown_finished)

	# Espera a física para coletar também alvos que já estavam dentro da área.
	await get_tree().physics_frame
	for target in get_overlapping_areas():
		_damage_target(target)

	await get_tree().create_timer(active_duration).timeout
	attack_is_active = false
	attack_visual.visible = false
	hit_shape.set_deferred("disabled", true)


func cancel_active_attack() -> void:
	attack_is_active = false
	attack_visual.visible = false
	hit_shape.set_deferred("disabled", true)

func _on_area_entered(area: Area2D) -> void:
	if attack_is_active:
		_damage_target(area)

func _damage_target(target: Area2D) -> void:
	if not attack_is_active or hit_targets.has(target) or not target.has_method("take_damage"):
		return

	hit_targets.append(target)
	target.call("take_damage", damage)

func _on_cooldown_finished() -> void:
	can_attack = true

func _update_position() -> void:
	position = facing_direction * (player_radius + attack_length / 2.0)
	rotation = facing_direction.angle() + PI / 2.0

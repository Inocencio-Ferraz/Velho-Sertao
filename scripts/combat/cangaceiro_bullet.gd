extends CharacterBody2D

@export var speed: float = 350.0
@export var max_distance: float = 500.0

var damage: int = 1
var _direction: Vector2 = Vector2.ZERO
var _distance_travelled: float = 0.0
var _launched: bool = false

@onready var visual: Polygon2D = $Visual
@onready var trail: Line2D = $Trail

func launch(
	direction: Vector2,
	damage_amount: int,
	target_collision_mask: int = 1,
	distance_limit: float = -1.0
) -> void:
	_direction = direction.normalized()
	damage = maxi(1, damage_amount)
	collision_mask = target_collision_mask
	var shot_color := Color(1.0, 0.9, 0.56, 1.0) if damage >= 10 else Color(1.0, 0.38, 0.24, 1.0)
	visual.color = shot_color
	trail.default_color = Color(shot_color.r, shot_color.g, shot_color.b, 0.55)
	if distance_limit > 0.0:
		max_distance = distance_limit
	rotation = _direction.angle()
	velocity = _direction * speed
	_launched = _direction != Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not _launched:
		return

	var remaining_distance := max_distance - _distance_travelled
	if remaining_distance <= 0.0:
		queue_free()
		return

	var frame_distance := minf(velocity.length() * delta, remaining_distance)
	var collision := move_and_collide(_direction * frame_distance)
	if collision:
		var target := collision.get_collider()
		if target is Node and target.has_method("take_damage"):
			target.call("take_damage", damage)
		queue_free()
		return

	_distance_travelled += frame_distance
	if _distance_travelled >= max_distance:
		queue_free()

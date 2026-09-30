extends CharacterBody2D

signal defeated(enemy: Node)

@export var speed: float = 80.0
@export var max_health: int = 30
@export var detection_range: float = 200.0
@export var attack_distance: float = 40.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.0
@export var attack_length: float = 42.0
@export var attack_width: float = 40.0
@export var attack_active_duration: float = 0.12

@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_visual: Polygon2D = $AttackArea/AttackVisual
@onready var hurtbox: Area2D = $Hurtbox
@onready var visual: Polygon2D = $Visual
@onready var direction_marker: Polygon2D = $DirectionMarker

enum State { IDLE, CHASE, ATTACK, DEAD }

var health: int = 30
var is_dead: bool = false
var _dialogue_locked: bool = false
var _state: State = State.IDLE
var _target_player: CharacterBody2D
var _facing_direction: Vector2 = Vector2.LEFT
var _attack_ready: bool = true
var _attack_is_active: bool = false
var _attack_has_hit: bool = false
var _hit_tween: Tween

func _ready() -> void:
	max_health = maxi(1, max_health)
	health = max_health

	var detection_circle := detection_shape.shape as CircleShape2D
	detection_circle.radius = detection_range
	var attack_rectangle := attack_shape.shape as RectangleShape2D
	attack_rectangle.size = Vector2(attack_width, attack_length)
	attack_shape.disabled = true
	attack_visual.visible = false
	attack_visual.polygon = PackedVector2Array([
		Vector2(-attack_width / 2.0, -attack_length / 2.0),
		Vector2(attack_width / 2.0, -attack_length / 2.0),
		Vector2(attack_width / 2.0, attack_length / 2.0),
		Vector2(-attack_width / 2.0, attack_length / 2.0)
	])

	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	attack_area.body_entered.connect(_on_attack_body_entered)
	_update_facing_visuals()

func _physics_process(_delta: float) -> void:
	if _dialogue_locked:
		velocity = Vector2.ZERO
		return

	match _state:
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()
		State.CHASE:
			_update_chase()
		State.ATTACK:
			_update_attack()
		State.DEAD:
			velocity = Vector2.ZERO

func set_dialogue_locked(locked: bool) -> void:
	_dialogue_locked = locked
	if locked:
		velocity = Vector2.ZERO
		_attack_is_active = false
		attack_visual.visible = false
		attack_shape.set_deferred("disabled", true)

func take_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	health = maxi(0, health - amount)
	_show_hit_feedback()
	print("Cangaceiro recebeu dano: ", amount, " | vida: ", health)

	if health == 0:
		_die()

func _on_detection_body_entered(body: Node2D) -> void:
	if is_dead or body == self or not body.has_method("take_damage"):
		return
	if body is CharacterBody2D:
		_target_player = body as CharacterBody2D
		_state = State.CHASE

func _on_detection_body_exited(body: Node2D) -> void:
	if body == _target_player:
		_lose_target()

func _update_chase() -> void:
	if not is_instance_valid(_target_player):
		_lose_target()
		return

	var offset_to_player := _target_player.global_position - global_position
	var distance_to_player := offset_to_player.length()
	# A DetectionArea controla a saída do alcance; não compare somente os centros,
	# pois o collider do Player também participa da detecção.
	_face_player(offset_to_player)
	if distance_to_player <= attack_distance:
		_state = State.ATTACK
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = offset_to_player.normalized() * speed
	move_and_slide()

func _update_attack() -> void:
	if not is_instance_valid(_target_player):
		_lose_target()
		return

	var offset_to_player := _target_player.global_position - global_position
	var distance_to_player := offset_to_player.length()
	# A DetectionArea controla a saída do alcance; não compare somente os centros,
	# pois o collider do Player também participa da detecção.
	_face_player(offset_to_player)
	if distance_to_player > attack_distance:
		_state = State.CHASE
		velocity = offset_to_player.normalized() * speed
		move_and_slide()
		return

	velocity = Vector2.ZERO
	move_and_slide()
	if _attack_ready and not _attack_is_active:
		_perform_attack()

func _perform_attack() -> void:
	_attack_ready = false
	_attack_is_active = true
	_attack_has_hit = false
	attack_visual.visible = true
	attack_shape.set_deferred("disabled", false)
	get_tree().create_timer(attack_cooldown).timeout.connect(_on_attack_cooldown_finished)

	await get_tree().physics_frame
	for body in attack_area.get_overlapping_bodies():
		_try_hit_player(body)

	await get_tree().create_timer(attack_active_duration).timeout
	_attack_is_active = false
	attack_visual.visible = false
	attack_shape.set_deferred("disabled", true)

func _on_attack_body_entered(body: Node2D) -> void:
	_try_hit_player(body)

func _try_hit_player(body: Node2D) -> void:
	if _dialogue_locked or not _attack_is_active or _attack_has_hit or body != _target_player:
		return
	if body.has_method("take_damage"):
		_attack_has_hit = true
		body.call("take_damage", attack_damage)

func _on_attack_cooldown_finished() -> void:
	_attack_ready = true

func _face_player(offset_to_player: Vector2) -> void:
	if offset_to_player == Vector2.ZERO:
		return
	if absf(offset_to_player.x) > absf(offset_to_player.y):
		_facing_direction = Vector2.RIGHT if offset_to_player.x > 0.0 else Vector2.LEFT
	else:
		_facing_direction = Vector2.DOWN if offset_to_player.y > 0.0 else Vector2.UP
	_update_facing_visuals()

func _update_facing_visuals() -> void:
	direction_marker.position = _facing_direction * 15.0
	direction_marker.rotation = _facing_direction.angle()
	attack_area.rotation = _facing_direction.angle() + PI / 2.0
	attack_area.position = _facing_direction * (10.0 + attack_length / 2.0)

func _lose_target() -> void:
	_target_player = null
	if not is_dead:
		_state = State.IDLE
		velocity = Vector2.ZERO

func _show_hit_feedback() -> void:
	if _hit_tween and _hit_tween.is_running():
		_hit_tween.kill()
	visual.color = Color(1.0, 0.75, 0.35, 1.0)
	_hit_tween = create_tween()
	_hit_tween.tween_property(visual, "color", Color(0.55, 0.2, 0.16, 1.0), 0.18)

func _die() -> void:
	is_dead = true
	defeated.emit(self)
	_state = State.DEAD
	velocity = Vector2.ZERO
	_attack_is_active = false
	attack_visual.visible = false
	attack_shape.set_deferred("disabled", true)
	body_shape.set_deferred("disabled", true)
	detection_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	print("Cangaceiro derrotado.")
	await get_tree().create_timer(0.2).timeout
	queue_free()

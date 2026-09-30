extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)
signal died

@export var speed: float = 200.0
@export var max_health: int = 3

var health: int = 3
var is_dead: bool = false
var controls_locked: bool = false
var facing_direction: Vector2 = Vector2.DOWN

@onready var direction_marker: Polygon2D = $DirectionMarker
@onready var melee_attack: Area2D = $MeleeAttack
@onready var pistol: Node2D = $Pistol

func _ready() -> void:
	_update_facing_visuals()
	max_health = maxi(1, max_health)
	health = clampi(health, 0, max_health)
	health_changed.emit(health, max_health)

func _physics_process(_delta: float) -> void:
	if is_dead or controls_locked:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing_direction = Vector2.RIGHT if direction.x > 0.0 else Vector2.LEFT
		else:
			facing_direction = Vector2.DOWN if direction.y > 0.0 else Vector2.UP
		_update_facing_visuals()

	velocity = direction * speed
	move_and_slide()

func set_controls_locked(locked: bool) -> void:
	controls_locked = locked
	if locked:
		velocity = Vector2.ZERO
		melee_attack.call("cancel_active_attack")
		pistol.call("hide_shot_flash")

func take_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)

	if health == 0:
		is_dead = true
		set_controls_locked(true)
		died.emit()

func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	health = mini(max_health, health + amount)
	health_changed.emit(health, max_health)

# TESTE: ações temporárias para validar vida, sem implementar combate.
func _unhandled_input(event: InputEvent) -> void:
	if controls_locked:
		return
	if event.is_action_pressed("test_damage"):
		take_damage(1)
	elif event.is_action_pressed("test_heal"):
		heal(1)

func _update_facing_visuals() -> void:
	direction_marker.position = facing_direction * 15.0
	direction_marker.rotation = facing_direction.angle() + PI / 2.0
	melee_attack.call("set_facing_direction", facing_direction)

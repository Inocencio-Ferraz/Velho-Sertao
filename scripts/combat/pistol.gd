extends Node2D

signal ammo_changed(current_ammo: int, maximum_ammo: int)

@export var max_ammo: int = 6
@export var damage: int = 15
@export var shot_range: float = 250.0
@export var cooldown: float = 0.4
@export var flash_duration: float = 0.08
@export_flags_2d_physics var hit_mask: int = 5

@onready var shot_line: Line2D = $ShotLine

var ammo: int = 6
var _can_fire: bool = true

func _ready() -> void:
	max_ammo = maxi(0, max_ammo)
	ammo = max_ammo
	shot_line.visible = false
	ammo_changed.emit(ammo, max_ammo)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pistol_fire"):
		_fire()

func _fire() -> void:
	var player := get_parent() as CharacterBody2D
	if not _can_fire or ammo <= 0 or bool(player.get("is_dead")) or bool(player.get("controls_locked")):
		return

	_can_fire = false
	ammo -= 1
	ammo_changed.emit(ammo, max_ammo)
	_shoot_in_facing_direction(player)
	get_tree().create_timer(cooldown).timeout.connect(_on_cooldown_finished)

func _shoot_in_facing_direction(player: CharacterBody2D) -> void:
	var direction: Vector2 = player.get("facing_direction")
	var ray_start := player.global_position + direction * 10.0
	var ray_end := ray_start + direction * shot_range
	var query := PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.collision_mask = hit_mask
	var excluded_rids: Array[RID] = [player.get_rid()]
	query.exclude = excluded_rids
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := player.get_world_2d().direct_space_state.intersect_ray(query)
	var shot_distance := shot_range
	if not result.is_empty():
		var hit_position: Vector2 = result["position"]
		shot_distance = ray_start.distance_to(hit_position)
		var target: Object = result["collider"]
		if target.has_method("take_damage"):
			target.call("take_damage", damage)

	_show_shot_flash(direction, shot_distance)

func _show_shot_flash(direction: Vector2, shot_distance: float) -> void:
	shot_line.points = PackedVector2Array([
		direction * 10.0,
		direction * (10.0 + shot_distance)
	])
	shot_line.visible = true
	get_tree().create_timer(flash_duration).timeout.connect(hide_shot_flash)

func hide_shot_flash() -> void:
	shot_line.visible = false

func _on_cooldown_finished() -> void:
	_can_fire = true

extends Node2D

const BULLET_SCENE: PackedScene = preload("res://scenes/combat/cangaceiro_bullet.tscn")

signal ammo_changed(current_ammo: int)

@export var damage: int = 15
@export var shot_range: float = 250.0
@export var cooldown: float = 0.4
@export_flags_2d_physics var hit_mask: int = 5

@onready var muzzle_flash: Polygon2D = $MuzzleFlash

var ammo: int = 6
var _can_fire: bool = true

func _ready() -> void:
	ammo_changed.emit(ammo)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pistol_fire"):
		_fire()

func _fire() -> void:
	var player := get_parent() as CharacterBody2D
	if not _can_fire or ammo <= 0 or bool(player.get("is_dead")) or bool(player.get("controls_locked")):
		return

	_can_fire = false
	ammo -= 1
	ammo_changed.emit(ammo)
	_shoot_in_facing_direction(player)
	get_tree().create_timer(cooldown).timeout.connect(_on_cooldown_finished)

func add_ammo(amount: int) -> void:
	if amount <= 0:
		return
	ammo += amount
	ammo_changed.emit(ammo)

func _shoot_in_facing_direction(player: CharacterBody2D) -> void:
	var direction: Vector2 = player.get("facing_direction")
	var bullet := BULLET_SCENE.instantiate() as CharacterBody2D
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = player.global_position + direction * 16.0
	bullet.call("launch", direction, damage, hit_mask, shot_range)
	_show_muzzle_flash(direction)

func _show_muzzle_flash(direction: Vector2) -> void:
	muzzle_flash.position = direction * 16.0
	muzzle_flash.rotation = direction.angle()
	muzzle_flash.visible = true
	get_tree().create_timer(0.06).timeout.connect(_hide_muzzle_flash)

func _hide_muzzle_flash() -> void:
	muzzle_flash.visible = false

func _on_cooldown_finished() -> void:
	_can_fire = true

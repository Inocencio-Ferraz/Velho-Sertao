extends "res://scripts/enemies/cangaceiro.gd"

@export var idle_phase_delay: float = 0.0
@export var idle_amplitude: float = 1.25
@export var idle_half_cycle: float = 1.4

@onready var dinosaur_sprite: Sprite2D = $Visual/DinosaurSprite

var _idle_tween: Tween
var _sprite_base_position: Vector2
var _sprite_base_scale: Vector2

func _ready() -> void:
	super._ready()
	_sprite_base_position = dinosaur_sprite.position
	_sprite_base_scale = dinosaur_sprite.scale
	_update_sprite_direction()
	if starts_dormant:
		_start_observation_idle()

func _face_player(offset_to_player: Vector2) -> void:
	super._face_player(offset_to_player)
	_update_sprite_direction()

func prepare_for_encounter() -> void:
	_stop_observation_idle()

func activate_encounter(target_player: CharacterBody2D) -> void:
	_stop_observation_idle()
	super.activate_encounter(target_player)

func _die() -> void:
	_stop_observation_idle()
	super._die()

func _start_observation_idle() -> void:
	if idle_phase_delay > 0.0:
		await get_tree().create_timer(idle_phase_delay, false).timeout
	if not starts_dormant or not is_instance_valid(dinosaur_sprite):
		return

	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(
		dinosaur_sprite,
		"position:y",
		_sprite_base_position.y - idle_amplitude,
		idle_half_cycle
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.tween_property(
		dinosaur_sprite,
		"position:y",
		_sprite_base_position.y,
		idle_half_cycle
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_observation_idle() -> void:
	if _idle_tween and _idle_tween.is_running():
		_idle_tween.kill()
	if is_instance_valid(dinosaur_sprite):
		dinosaur_sprite.position = _sprite_base_position
		dinosaur_sprite.scale = _sprite_base_scale

func _update_sprite_direction() -> void:
	if is_instance_valid(dinosaur_sprite):
		# A arte original olha para a direita; flip_h inverte apenas o dinossauro à direita.
		dinosaur_sprite.flip_h = _facing_direction.x < 0.0

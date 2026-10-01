extends Area2D

@export var camera_path: NodePath
@export var initial_pause: float = 0.18
@export var shake_duration: float = 2.0
@export var shake_strength: float = 7.5
@export var roar_pause: float = 0.3

@onready var camera: Camera2D = get_node_or_null(camera_path) as Camera2D

var _activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _activated or not body.is_in_group("player"):
		return

	_activated = true
	set_deferred("monitoring", false)
	for dinosaur in get_tree().get_nodes_in_group("dinosaur_guardian"):
		if is_instance_valid(dinosaur) and dinosaur.has_method("prepare_for_encounter"):
			dinosaur.call("prepare_for_encounter")
	_play_activation_sequence(body as CharacterBody2D)

func _play_activation_sequence(player: CharacterBody2D) -> void:
	await get_tree().create_timer(initial_pause, false).timeout
	if not is_instance_valid(player):
		return

	if is_instance_valid(camera):
		camera.call("shake", shake_duration, shake_strength)

	var roar_duration := 0.0
	var audio_manager := get_tree().get_first_node_in_group("game_audio")
	if audio_manager:
		if audio_manager.has_method("play_dinosaur_roar"):
			roar_duration = float(audio_manager.call("play_dinosaur_roar"))
		else:
			audio_manager.call("play_sfx", "dinosaur_roar")

	await get_tree().create_timer(maxf(shake_duration, roar_duration), false).timeout
	await get_tree().create_timer(roar_pause, false).timeout
	if not is_instance_valid(player):
		return

	for dinosaur in get_tree().get_nodes_in_group("dinosaur_guardian"):
		if is_instance_valid(dinosaur) and dinosaur.has_method("activate_encounter"):
			dinosaur.call("activate_encounter", player)

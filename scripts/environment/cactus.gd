extends Area2D

@onready var visual: Node2D = $Visual

var _player_in_range: CharacterBody2D
var _used: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact(player: Node2D) -> void:
	if _used or not is_instance_valid(_player_in_range) or player != _player_in_range:
		return
	if bool(_player_in_range.get("is_dead")) or bool(_player_in_range.get("controls_locked")):
		return

	var current_health := int(_player_in_range.get("health"))
	var maximum_health := int(_player_in_range.get("max_health"))
	if current_health >= maximum_health:
		return

	_used = true
	var prompt := get_tree().get_first_node_in_group("interaction_prompt")
	if prompt:
		prompt.call("unregister_candidate", self)
	_player_in_range.call("heal", 1)
	monitoring = false
	monitorable = false
	visual.visible = false
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("heal"):
		_player_in_range = body as CharacterBody2D
		var prompt := get_tree().get_first_node_in_group("interaction_prompt")
		if prompt:
			prompt.call("register_candidate", self, "[E] Usar cacto", 1, _player_in_range)

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		var prompt := get_tree().get_first_node_in_group("interaction_prompt")
		if prompt:
			prompt.call("unregister_candidate", self)
		_player_in_range = null

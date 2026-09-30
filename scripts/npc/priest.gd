extends StaticBody2D

@export var dialogue_box_path: NodePath
@export var story_progress_path: NodePath

@onready var dialogue_box: Node = get_node(dialogue_box_path)
@onready var story_progress: Node = get_node(story_progress_path)
@onready var attention_mark: Label = $AttentionMark

var _player_in_range: CharacterBody2D

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	dialogue_box.connect("dialogue_completed", _on_dialogue_completed)
	var float_tween := create_tween().set_loops()
	float_tween.tween_property(attention_mark, "position:y", -50.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(attention_mark, "position:y", -46.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func interact(player: Node2D) -> void:
	if not is_instance_valid(_player_in_range) or player != _player_in_range:
		return
	if bool(dialogue_box.get("is_open")):
		return

	var lines := PackedStringArray([
		"Meu filho, você parece estar com muita sede...",
		"Há três poços por estas bandas.",
		"Procure por eles. Talvez encontre água em algum deles."
	])
	dialogue_box.call("start_dialogue", "Padre", lines)

func _on_dialogue_completed(speaker: String) -> void:
	if speaker == "Padre":
		story_progress.call("mark_priest_conversation_finished")

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("heal"):
		_player_in_range = body as CharacterBody2D
		var prompt := get_tree().get_first_node_in_group("interaction_prompt")
		if prompt:
			prompt.call("register_candidate", self, "[E] Falar com o Padre", 2, _player_in_range)

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		var prompt := get_tree().get_first_node_in_group("interaction_prompt")
		if prompt:
			prompt.call("unregister_candidate", self)
		_player_in_range = null

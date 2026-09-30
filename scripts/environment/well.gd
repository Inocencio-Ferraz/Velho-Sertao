extends StaticBody2D

@export var dialogue_box_path: NodePath
@export var story_progress_path: NodePath

@onready var dialogue_box: Node = get_node(dialogue_box_path)
@onready var story_progress: Node = get_node(story_progress_path)
@onready var dry_visual: Polygon2D = $DryCenter

var _player_in_range: CharacterBody2D
var _living_enemy_count: int = 0
var _defeated_enemies: Dictionary = {}
var _unlocked: bool = false
var _completed: bool = false

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

	for enemy in get_tree().get_nodes_in_group("first_well_enemy"):
		if bool(enemy.get("is_dead")) or not enemy.has_signal("defeated"):
			continue
		_living_enemy_count += 1
		enemy.connect("defeated", _on_enemy_defeated)

	_unlocked = _living_enemy_count == 0
	_update_prompt()

func interact(player: Node2D) -> void:
	if _completed or not _unlocked or player != _player_in_range:
		return
	if bool(player.get("is_dead")) or bool(player.get("controls_locked")):
		return

	_completed = true
	_update_prompt()
	dry_visual.color = Color(0.2, 0.16, 0.12, 1.0)
	story_progress.call("complete_first_well")
	dialogue_box.call("start_dialogue", "Poço", PackedStringArray([
		"Está seco...",
		"Melhor ver o segundo poço."
	]))

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("heal"):
		_player_in_range = body as CharacterBody2D
		_update_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		var prompt := get_tree().get_first_node_in_group("interaction_prompt")
		if prompt:
			prompt.call("unregister_candidate", self)
		_player_in_range = null

func _on_enemy_defeated(enemy: Node) -> void:
	if _defeated_enemies.has(enemy):
		return
	_defeated_enemies[enemy] = true
	_living_enemy_count = maxi(0, _living_enemy_count - 1)
	story_progress.call("begin_first_well_encounter")
	if _living_enemy_count == 0:
		_unlocked = true
	_update_prompt()

func _update_prompt() -> void:
	var prompt := get_tree().get_first_node_in_group("interaction_prompt")
	if not prompt:
		return
	if _unlocked and not _completed and is_instance_valid(_player_in_range):
		prompt.call("register_candidate", self, "[E] Examinar o poço", 2, _player_in_range)
	else:
		prompt.call("unregister_candidate", self)

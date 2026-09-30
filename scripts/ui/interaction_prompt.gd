extends CanvasLayer

@onready var panel: PanelContainer = $PromptPanel
@onready var prompt_label: Label = $PromptPanel/MarginContainer/PromptLabel

var _candidates: Dictionary = {}
var _player: Node2D
var _dialogue_active: bool = false
var _selected: Node2D

func _ready() -> void:
	panel.visible = false

func register_candidate(interactable: Node2D, message: String, priority: int, player: Node2D) -> void:
	_candidates[interactable] = {"message": message, "priority": priority}
	_player = player
	_refresh_prompt()

func unregister_candidate(interactable: Node2D) -> void:
	_candidates.erase(interactable)
	_refresh_prompt()

func set_dialogue_active(active: bool) -> void:
	_dialogue_active = active
	_refresh_prompt()

func _process(_delta: float) -> void:
	_refresh_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if _dialogue_active or not event.is_action_pressed("interact"):
		return
	if not is_instance_valid(_selected):
		return
	if _selected.has_method("interact"):
		_selected.call("interact", _player)
		get_viewport().set_input_as_handled()

func _refresh_prompt() -> void:
	if _dialogue_active or not is_instance_valid(_player):
		panel.visible = false
		return

	var selected: Node2D
	var selected_data: Dictionary = {}
	var highest_priority := -1
	var shortest_distance := INF

	for candidate in _candidates.keys():
		if not is_instance_valid(candidate):
			_candidates.erase(candidate)
			continue
		var data: Dictionary = _candidates[candidate]
		var distance := _player.global_position.distance_squared_to(candidate.global_position)
		var priority: int = data["priority"]
		if priority > highest_priority or (priority == highest_priority and distance < shortest_distance):
			selected = candidate
			selected_data = data
			highest_priority = priority
			shortest_distance = distance

	panel.visible = is_instance_valid(selected)
	_selected = selected
	if panel.visible:
		prompt_label.text = selected_data["message"]

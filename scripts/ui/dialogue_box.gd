extends CanvasLayer

signal dialogue_completed(speaker: String)

@export var player_path: NodePath
@export var interaction_prompt_path: NodePath
@export var opening_speaker: String = ""
@export var opening_lines: PackedStringArray = PackedStringArray()

@onready var panel: Control = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/DialogueLabel
@onready var continue_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/ContinueLabel
@onready var player: Node = get_node(player_path)
@onready var interaction_prompt: Node = get_node(interaction_prompt_path)

var is_open: bool = false
var _lines: PackedStringArray = PackedStringArray()
var _line_index: int = 0

func _ready() -> void:
	panel.visible = false
	if not opening_lines.is_empty():
		call_deferred("_start_opening_sequence")

func _start_opening_sequence() -> void:
	start_dialogue(opening_speaker, opening_lines)

func start_dialogue(speaker: String, lines: PackedStringArray) -> void:
	if is_open or lines.is_empty():
		return

	_lines = lines
	_line_index = 0
	speaker_label.text = speaker
	is_open = true
	panel.visible = true
	_set_gameplay_locked(true)
	interaction_prompt.call("set_dialogue_active", true)
	_show_current_line()

func _input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed("interact"):
		_advance_dialogue()
		get_viewport().set_input_as_handled()

func _advance_dialogue() -> void:
	_line_index += 1
	if _line_index >= _lines.size():
		_finish_dialogue()
		return
	_show_current_line()

func _show_current_line() -> void:
	dialogue_label.text = _lines[_line_index]
	continue_label.text = "E — continuar"

func _finish_dialogue() -> void:
	var finished_speaker := speaker_label.text
	is_open = false
	panel.visible = false
	_set_gameplay_locked(false)
	interaction_prompt.call("set_dialogue_active", false)
	dialogue_completed.emit(finished_speaker)

func _set_gameplay_locked(locked: bool) -> void:
	if is_instance_valid(player):
		player.call("set_controls_locked", locked)

	for enemy in get_tree().get_nodes_in_group("dialogue_interruptible"):
		if enemy.has_method("set_dialogue_locked"):
			enemy.call("set_dialogue_locked", locked)

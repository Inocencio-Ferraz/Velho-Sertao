extends CanvasLayer

@onready var overlay: Control = $Overlay
@onready var continue_button: Button = $Overlay/CenterPanel/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false
	continue_button.pressed.connect(_on_continue_pressed)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause_game"):
		return

	var game_over := get_tree().get_first_node_in_group("game_over")
	if game_over and bool(game_over.get("is_open")):
		get_viewport().set_input_as_handled()
		return

	_toggle_pause()
	get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	var should_pause := not get_tree().paused
	get_tree().paused = should_pause
	overlay.visible = should_pause
	_set_audio_paused(should_pause)

	if should_pause:
		continue_button.grab_focus()
	else:
		continue_button.release_focus()

func _on_continue_pressed() -> void:
	get_tree().paused = false
	overlay.visible = false
	_set_audio_paused(false)
	continue_button.release_focus()

func _set_audio_paused(paused: bool) -> void:
	var audio_manager := get_tree().get_first_node_in_group("game_audio")
	if audio_manager:
		audio_manager.call("set_game_paused", paused)

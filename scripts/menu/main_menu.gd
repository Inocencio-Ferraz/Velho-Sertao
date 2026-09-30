extends Control

@onready var start_button: Button = $CenterPanel/MarginContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CenterPanel/MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()

func _on_start_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	if error != OK:
		push_error("Não foi possível iniciar a partida: %s" % error_string(error))

func _on_quit_pressed() -> void:
	get_tree().quit()

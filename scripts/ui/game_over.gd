extends CanvasLayer

@export var player_path: NodePath

@onready var overlay: Control = $Overlay
@onready var retry_button: Button = $Overlay/CenterPanel/MarginContainer/VBoxContainer/RetryButton
@onready var menu_button: Button = $Overlay/CenterPanel/MarginContainer/VBoxContainer/MenuButton
@onready var player: Node = get_node(player_path)

var is_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false
	player.connect("died", _on_player_died)
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(return_to_menu)

func _on_player_died() -> void:
	is_open = true
	overlay.visible = true
	get_tree().paused = true
	retry_button.grab_focus()

func _on_retry_pressed() -> void:
	is_open = false
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	if error != OK:
		push_error("Não foi possível reiniciar a partida: %s" % error_string(error))

func return_to_menu() -> void:
	is_open = false
	get_tree().paused = false
	var error := get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
	if error != OK:
		push_error("Não foi possível voltar ao menu: %s" % error_string(error))

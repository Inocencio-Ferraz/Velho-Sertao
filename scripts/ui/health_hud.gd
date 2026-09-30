extends CanvasLayer

@export var player_path: NodePath

@onready var hearts_label: Label = $Control/HeartsLabel
@onready var player: Node = get_node(player_path)

var _last_health: int = -1
var _heal_feedback_tween: Tween

func _ready() -> void:
	player.connect("health_changed", Callable(self, "_on_health_changed"))
	_on_health_changed(int(player.get("health")), int(player.get("max_health")))

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	var hearts := ""
	for heart_index in range(maximum_health):
		if heart_index > 0:
			hearts += " "
		hearts += "♥" if heart_index < current_health else "♡"
	hearts_label.text = hearts
	if _last_health >= 0 and current_health > _last_health:
		_show_heal_feedback()
	_last_health = current_health

func _show_heal_feedback() -> void:
	if _heal_feedback_tween and _heal_feedback_tween.is_running():
		_heal_feedback_tween.kill()
	hearts_label.modulate = Color(0.72, 1.0, 0.62, 1.0)
	_heal_feedback_tween = create_tween()
	_heal_feedback_tween.tween_property(hearts_label, "modulate", Color.WHITE, 0.35)

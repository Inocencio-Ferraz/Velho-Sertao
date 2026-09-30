extends CanvasLayer

@export var player_path: NodePath

@onready var hearts_label: Label = $Control/HeartsLabel
@onready var player: Node = get_node(player_path)

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

extends CanvasLayer

@export var pistol_path: NodePath

@onready var ammo_label: Label = $Control/AmmoLabel
@onready var pistol: Node = get_node(pistol_path)

func _ready() -> void:
	pistol.connect("ammo_changed", Callable(self, "_on_ammo_changed"))
	_on_ammo_changed(int(pistol.get("ammo")), int(pistol.get("max_ammo")))

func _on_ammo_changed(current_ammo: int, _maximum_ammo: int) -> void:
	ammo_label.text = "BALAS: %d" % current_ammo

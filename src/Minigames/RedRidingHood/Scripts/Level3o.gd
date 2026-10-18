extends Node2D

@export var game_settings: NodePath = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.cutscene = true
	$Player.direction = -1.0
	var tween: Tween = create_tween()
	tween.tween_property($CanvasLayer/Control/Fade, "modulate", Color(1.0, 1.0, 1.0, 0.5), 1.0)
	tween.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

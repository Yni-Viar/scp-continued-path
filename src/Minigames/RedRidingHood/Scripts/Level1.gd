extends Node2D

@export var game_settings: NodePath = ""

@onready var root: Viewport = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_dialogue_box_dialogue_signal(value: String) -> void:
	match value:
		"wolf_deny":
			#Settings.route = Settings.GameRoute.HAPPYEND
			var tween: Tween = create_tween()
			tween.tween_property($Wolf, "modulate", Color(0, 0, 0, 0), 1.0)
			tween.play()
			await tween.finished
			$Wolf.queue_free()
			$Player.cutscene = true
			$Player.direction = 1.0
			tween = create_tween()
			tween.tween_property($CanvasLayer/Control/Fade, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
			tween.play()
			await get_tree().create_timer(2.0).timeout
			get_node(game_settings).change_scene("res://Minigames/RedRidingHood/Scenes/Level2H.tscn")
		"wolf_faster_canon":
			#Settings.route = Settings.GameRoute.CANON
			$Wolf.direction = 1.0
			await get_tree().create_timer(2.0).timeout
			$Player.cutscene = true
			$Player.direction = 1.0
			var tween: Tween = create_tween()
			tween.tween_property($CanvasLayer/Control/Fade, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
			tween.play()
			await get_tree().create_timer(2.0).timeout
			get_node(game_settings).change_scene("res://Minigames/RedRidingHood/Scenes/Level2C.tscn")
		"wolf_slower_outsmart":
			#Settings.route = Settings.GameRoute.OUTSMART
			$Wolf.direction = 1.0
			await get_tree().create_timer(2.0).timeout
			$Player.cutscene = true
			$Player.direction = 1.0
			var tween: Tween = create_tween()
			tween.tween_property($CanvasLayer/Control/Fade, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
			tween.play()
			await get_tree().create_timer(2.0).timeout
			get_node(game_settings).change_scene("res://Minigames/RedRidingHood/Scenes/Level2O.tscn")
	


func _on_no_way_back_body_entered(body: Node2D) -> void:
	if body is RRHPlayerScript:
		root.get_node("Game/CanvasLayer/Control/DialogueBox").start("dlg_nwb")
		root.get_node("Game/CanvasLayer/Control/DialogueBox").show()


func _on_h_slider_changed() -> void:
	$Player.direction = $CanvasLayer/Control/HSlider.value


func _on_right_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		$Player.direction = -1.0


func _on_left_bar_toggled(toggled_on: bool) -> void:
	if toggled_on && $Player.direction <= 0.0001:
		$Player.direction = -1.0
	else:
		$Player.direction = 0.0


func _on_right_bar_toggled(toggled_on: bool) -> void:
	if toggled_on && $Player.direction >= -0.0001:
		$Player.direction = 1.0
	else:
		$Player.direction = 0.0

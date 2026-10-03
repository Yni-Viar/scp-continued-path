extends RoomPrefab
## SCP-812 trigger script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

@export var flowing = false

@onready var waterflow: MeshInstance3D = $WaterFlow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if flowing && waterflow.position.y < -9:
		waterflow.position.y += delta
	elif waterflow.visible && waterflow.position.y > -30.5:
		waterflow.position.y -= delta

func flow():
	if get_node_or_null("Waterfall") != null:
		$Waterfall.emitting = flowing
	if get_node_or_null("Waterfall2") != null:
		$Waterfall2.emitting = flowing
	if get_node_or_null("Waterfall3") != null:
		$Waterfall3.emitting = flowing
	waterflow.visible = flowing

func open_sound():
	var sound: AudioStream = load("res://Sounds/Environment/Scp812/deleted_user_7146007__opening-old-garage-door.ogg")
	if get_node_or_null("NavigationRegion3D/Scp812/AudioStreamPlayer3D") != null:
		$NavigationRegion3D/Scp812/AudioStreamPlayer3D.stream = sound
		$NavigationRegion3D/Scp812/AudioStreamPlayer3D.play()
	$WaterfallSound.play()
	var tween: Tween = create_tween()
	tween.tween_property($WaterfallSound, "volume_db", 0.0, 1.0)

func close_sound():
	var sound: AudioStream = load("res://Sounds/Environment/Scp812/deleted_user_7146007__locking-old-garage-door.ogg")
	if get_node_or_null("NavigationRegion3D/Scp812/AudioStreamPlayer3D") != null:
		$NavigationRegion3D/Scp812/AudioStreamPlayer3D.stream = sound
		$NavigationRegion3D/Scp812/AudioStreamPlayer3D.play()
	var tween: Tween = create_tween()
	if get_node_or_null("WaterfallSound") != null:
		tween.tween_property($WaterfallSound, "volume_db", -20.0, 1.0)
		tween.finished.connect(disable_waterfall_sound)

func _on_scp_812_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			open_sound()
			if !flowing:
				if get_node_or_null("AnimationPlayer") != null:
					$AnimationPlayer.play("open_waterflow")
				flowing = true


func _on_scp_812_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			close_sound()
			if flowing:
				if get_node_or_null("AnimationPlayer") != null:
					$AnimationPlayer.play_backwards("open_waterflow")
				#Achievement
				if Settings.setting_res.scp_study_progress_all.has("SCP-812"):
					if !Settings.setting_res.scp_study_progress_all["SCP-812"]:
						Settings.setting_res.scp_study_progress_all["SCP-812"] = true
						Settings.save_resource(Settings.setting_res)
				get_tree().root.get_node("Game/FoundationTask").do_task("task_812")
				flowing = false
				
				for deer in get_tree().get_nodes_in_group("Scp2845"):
					if deer is Scp2845PuppetScript:
						deer.activate()

func disable_waterfall_sound():
	$WaterfallSound.stop()


func _on_splash_trigger_body_entered(body: Node3D) -> void:
	if body is Pickable:
		$WaterFlow/InteractSound.play()

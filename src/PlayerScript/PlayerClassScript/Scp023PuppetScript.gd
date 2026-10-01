extends SkinnablePuppetScript
## SCP-023 puppet script.
## It is like a delayed timeb0mb with warning.
## It appears in late round, you need to come to repair eyes. Won't do it - catch gameover.
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp023PuppetScript

var eye_glow_strength: float = 0.25

@export var glow_enabled: bool = false
var timer: Timer

func on_spawned() -> void:
	plugin_api_function("start")
	if get_tree().root.get_node_or_null("Game/StoryModeNode") == null:
		glow_enabled = false if get_tree().root.get_node("Game").rng.randi_range(0, 1) == 1 else true
	await get_tree().create_timer(0.5).timeout
	if glow_enabled:
		if !get_tree().root.get_node("Game/FoundationTask").has_task("task_023_emergency"):
			get_tree().root.get_node("Game/FoundationTask").trigger_event(2, load("res://Scripts/TaskSystem/Tasks/Scp023EmergencyTask.tres"))
			timer = get_node(get_tree().root.get_node("Game/FoundationTask").all_tasks["task_023_emergency"].timer_path)

func _physics_process(delta: float) -> void:
	plugin_api_function("update")
	match state:
		States.IDLE:
			call("set_state", "idle")
		States.WALKING:
			call("set_state", "walk")
	puppet_node.get_node("rig_001_deform/Skeleton3D/Plane").mesh.surface_get_material(2).set_shader_parameter("emission_strength", eye_glow_strength)
	# If eye glowing too strong, activate 023 event
	if glow_enabled && timer != null:
		if !timer.is_stopped():
			eye_glow_strength = lerpf(0.25, 2.0, (timer.wait_time - timer.time_left) / timer.wait_time)


## Animation state
func set_state(anim_name: String) -> void:
	# if animation is the same, do nothing, else play new animation
	if puppet_node.get_node("AnimationPlayer").current_animation == anim_name:
		return
	puppet_node.get_node("AnimationPlayer").play(anim_name, 0.3)

#func _on_timer_timeout() -> void:
	#get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_SCP_023")

func special_action():
	plugin_api_function("special_action")
	if glow_enabled:
		eye_glow_strength = 0.25
		timer.stop()
		#Achievement
		if Settings.setting_res.scp_study_progress_all.has("SCP-023"):
			if !Settings.setting_res.scp_study_progress_all["SCP-023"]:
				Settings.setting_res.scp_study_progress_all["SCP-023"] = true
				Settings.save_resource(Settings.setting_res)
		if get_tree().root.get_node("Game/FoundationTask").has_task("task_023_emergency"):
			get_tree().root.get_node("Game/FoundationTask").trigger_event(0)

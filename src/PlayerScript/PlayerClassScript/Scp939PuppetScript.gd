extends SkinnablePuppetScript
## SCP-939 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp939PuppetScript

var heat_targets: Array[Node3D] = []

## Attack timer
var attack_update_timer: float = 0.0

var is_attacking: bool = false
var current_target: Node3D

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	if !get_parent().get_parent().get_node("ActionArea").body_entered.is_connected(on_action_area_body_entered):
		get_parent().get_parent().get_node("ActionArea").connect("body_entered", on_action_area_body_entered)
	if !get_parent().get_parent().get_node("ActionArea").body_exited.is_connected(on_action_area_body_exited):
		get_parent().get_parent().get_node("ActionArea").connect("body_exited", on_action_area_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			set_state("939_Idle")
		States.WALKING:
			set_state("939_Walking")
		States.RUNNING:
			set_state("939_Running")
	if is_attacking:
		attack()

func set_state(anim: String):
	if puppet_node.get_node("AnimationPlayer").current_animation != anim:
		puppet_node.get_node("AnimationPlayer").play(anim)

func attack():
	if attack_update_timer > 0:
		attack_update_timer -= get_physics_process_delta_time()
	else:
		current_target = get_node(get_parent().get_parent().follow_target)
		if current_target != null:
			set_state("939_Attack" + str(rng.randi_range(1, 3)))
			current_target.health_manage(-100.0, 0, "GAME_OVER_SCP_939")
			heat_targets.erase(current_target)
			current_target = null
			if heat_targets.size() > 0:
				get_parent().get_parent().follow_target = heat_targets[0].get_path()
			else:
				get_parent().get_parent().follow_target = ""
				get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER
		attack_update_timer = 2.0

## Apply amnestic and go to target
func _on_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.fraction == 0 && body.puppet_class.team < 2048:
			if body.is_player:
				body.get_node("StatusEffects").apply_status_effect("Amnesia", 1.0, 0.0)
			#Achievement
			if Settings.setting_res.scp_study_progress_all.has("SCP-939"):
				if !Settings.setting_res.scp_study_progress_all["SCP-939"]:
					Settings.setting_res.scp_study_progress_all["SCP-939"] = true
					Settings.save_resource(Settings.setting_res)
			heat_targets.append(body)
			get_parent().get_parent().follow_target = body.get_path()
			get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.NONE

func _on_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name != "SCP-939":
			if body.is_player:
				body.get_node("StatusEffects").apply_status_effect("Amnesia", 0.0, 0.0)
			heat_targets.erase(body)
			if heat_targets.is_empty():
				get_parent().get_parent().follow_target = ""
				get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER

func on_action_area_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name != "SCP-939":
			is_attacking = true

func on_action_area_body_exited(body: Node3D) -> void:
	if body is MovableNpc && body == get_node(get_parent().get_parent().follow_target):
		is_attacking = false

func _on_run_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc && heat_targets.has(body) && body.puppet_class.puppet_class_name != "SCP-939":
		get_parent().get_parent().character_speed = 12.0


func _on_run_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc && heat_targets.has(body) && body.puppet_class.puppet_class_name != "SCP-939":
		get_parent().get_parent().character_speed = 6.0

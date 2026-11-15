extends VisionScpPuppetScript
## SCP-650 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp650PuppetScript

@export var wait_seconds: float = 5
var timer = 0
var has_animations: bool = true

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	if puppet_node.get_node_or_null("AnimationPlayer") == null:
		has_animations = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#If is not watching
	if watching_puppets.size() == 0:
		#Wait
		timer += delta
		if timer >= wait_seconds:
			var players = get_tree().get_nodes_in_group("Players")
			var random_human: Node3D = players[rng.randi_range(0, players.size() - 1)]
			#Action. We move SCP-650 to player's global position - offset (which is transform.basis.z) * how far SCP-650 will be from player
			get_parent().get_parent().global_position = random_human.global_position - random_human.global_transform.basis.z * 2
			#Achievement
			if Settings.setting_res.scp_study_progress_all.has("SCP-650"):
				if !Settings.setting_res.scp_study_progress_all["SCP-650"]:
					Settings.setting_res.scp_study_progress_all["SCP-650"] = true
					Settings.save_resource(Settings.setting_res)
			if has_animations:
				var pose: String = "Pose " + str(rng.randi_range(4, 10))
				set_state(pose)
			# Look at player
			look_at(random_human.global_position)
			# reset timer
			timer = 0
	else:
		# reset timer
		timer = 0

## Animation state
func set_state(s):
	# if animation is the same, do nothing, else play new animation
	if puppet_node.get_node("AnimationPlayer").current_animation == s:
		return
	puppet_node.get_node("AnimationPlayer").play(s, 0.3)

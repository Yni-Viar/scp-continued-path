extends SkinnablePuppetScript
## SCP-131 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp131PuppetScript

@export_group("DO NOT TOUCH!")
@export var looking_at_target: bool = false
@export var elapsed_time: float = 0.0

# Called when the node enters the scene tree for the first time.
#func on_spawned():
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	## Look at enemy
	if active_puppets.size() > 0 && state == States.IDLE:
		var prev_entity_distance: float = 16777216
		var index = 0
		# Fixing scientist not looking at 650 - now people will look at the nearest object
		for i in range(active_puppets.size()):
			var entity_distance: float = active_puppets[i].global_position.distance_to(get_parent().global_position)
			if entity_distance < prev_entity_distance || i == active_puppets.size() - 1:
				prev_entity_distance = entity_distance
				index = i
		
		var looking_object: Node3D
		
		# If there is must-not-look SCP (like 023), just watch SafePoint. Else, look directly, as 173 or 650
		if active_puppets[index].puppet_class.fraction == 3 && \
		active_puppets[index].get_node_or_null("PlayerModel/Puppet/SafeZone") != null:
			looking_object = active_puppets[index].get_node("PlayerModel/Puppet/SafeZone")
		else:
			looking_object = active_puppets[index]
		
		if active_puppets[index].puppet_class.fraction != 3:
			get_parent().get_parent().look_at(looking_object.global_position)
			get_parent().get_parent().get_node("RayCast3D").look_at(looking_object.global_position)
			elapsed_time += delta
			if elapsed_time > 2.0:
				if active_puppets.has(get_parent().get_parent().get_node("RayCast3D").get_collider()):
					get_parent().get_parent().wandering = false
					get_parent().get_parent().follow_target = ""
				else:
					elapsed_time = 0.0
		else:
			elapsed_time = 0.0
		looking_at_target = true
	else:
		elapsed_time = 0.0


func _on_achievement_screen_entered() -> void:
	#Achievement
	if Settings.setting_res.scp_study_progress_all.has("SCP-131"):
		if !Settings.setting_res.scp_study_progress_all["SCP-131"]:
			Settings.setting_res.scp_study_progress_all["SCP-131"] = true
			Settings.save_resource(Settings.setting_res)

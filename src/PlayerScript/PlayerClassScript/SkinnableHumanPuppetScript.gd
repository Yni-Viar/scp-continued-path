extends SkinnablePuppetScript
## Puppet script, that is used by all civilian humans and is base for SCP-347, MTF and Chaos insurgent
## Made by Yni, licensed under MIT license.
class_name SkinnableHumanPuppetScript

enum SecondaryState {NONE, ITEM, CUFFED, JAILBIRD_ATTACK, INTERACT, MTF_RIFLE, CI_RIFLE, HAT}

const SECONDARY_STATE_ALIAS: Dictionary[SecondaryState, String] = {
	SecondaryState.ITEM: "item",
	SecondaryState.CUFFED: "cuffed",
	SecondaryState.JAILBIRD_ATTACK: "jailbird_attack",
	SecondaryState.INTERACT: "interact",
	SecondaryState.CI_RIFLE: "ci_rifle",
	SecondaryState.HAT: "hat"
}

@export var enable_secondary_state: bool = true
@export var secondary_state: SecondaryState = SecondaryState.NONE
@export var resistance_scp178: bool = false
@export var resistance_scp686: bool = false
@export var torso_node_path: NodePath
@export var current_item: int = 0

var scp_067_affected: bool = false

var cuffed_players: Array[MovableNpc] = []
var raycast: RayCast3D
var vision_entity: Array = []
var has_animtree: bool = false
var has_lookat_ik: bool = false
var looking_at_target: bool = false
var update_timer = 1.0
var effect_update_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	raycast = get_parent().get_parent().get_node("RayCast3D")
	if puppet_node.get_node_or_null("AnimationTree") != null:
		puppet_node.get_node("AnimationTree").active = true
		has_animtree = true
	if puppet_node.get_node_or_null(armature_name + "/Skeleton3D/LookAtModifier3D") != null && get_parent().get_parent().puppet_class.enable_ik:
		has_lookat_ik = true
	
	
	if puppet_node.get_node_or_null(torso_node_path) == null:
		resistance_scp686 = true
	
	on_start_human()

func on_start_human():
	plugin_api_function("start")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Change animation state
	if has_animtree && !get_parent().get_parent().optimizator_paused:
		match state:
			States.IDLE:
				if !puppet_node.get_node("AnimationTree").get("parameters/state_machine/blend_amount") - 0.00001 < -1:
					call("set_state", "state_machine", "blend_amount", lerp(puppet_node.get_node("AnimationTree").get("parameters/state_machine/blend_amount"), -1.0, get_parent().get_parent().character_speed * delta))
			States.WALKING:
				if !puppet_node.get_node("AnimationTree").get("parameters/state_machine/blend_amount") + 0.00001 > 0:
					call("set_state", "state_machine", "blend_amount", lerp(puppet_node.get_node("AnimationTree").get("parameters/state_machine/blend_amount"), 0.0, get_parent().get_parent().character_speed * delta))
			States.RUNNING:
				if !puppet_node.get_node("AnimationTree").get("parameters/state_machine/blend_amount") + 0.00001 > 1:
					call("set_state", "state_machine", "blend_amount", lerp(puppet_node.get_node("AnimationTree").get("parameters/state_machine/blend_amount"), 1.0, get_parent().get_parent().character_speed * delta))
		if enable_secondary_state:
			match secondary_state:
				SecondaryState.NONE:
					if !puppet_node.get_node("AnimationTree").get("parameters/items_blend/blend_amount") - 0.00001 < 0:
						call("set_state", "items_blend", "blend_amount", lerp(puppet_node.get_node("AnimationTree").get("parameters/items_blend/blend_amount"), 0.0, get_parent().get_parent().character_speed * delta))
				_:
					call("set_state", "secondary_state", "transition_request", SECONDARY_STATE_ALIAS[secondary_state])
			if secondary_state != SecondaryState.NONE:
				if !puppet_node.get_node("AnimationTree").get("parameters/items_blend/blend_amount") + 0.00001 > 1:
					call("set_state", "items_blend", "blend_amount", lerp(puppet_node.get_node("AnimationTree").get("parameters/items_blend/blend_amount"), 1.0, get_parent().get_parent().character_speed * delta))
	
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
		
		# SCP-023 is still on BasePuppetScript, save the old detection code...
		# If there is must-not-look SCP (like 023), just watch SafePoint. Else, look directly, as 173 or 650
		#if active_puppets[index].puppet_class.fraction == 3 && \
		#active_puppets[index].get_node_or_null("PlayerModel/Puppet") != null:
			#if active_puppets[index].get_node("PlayerModel/Puppet").puppet_node.get_node_or_null("SafeZone") != null:
				#looking_object = active_puppets[index].get_node("PlayerModel/Puppet").puppet_node.get_node("SafeZone")
			#else:
				#looking_object = active_puppets[index]
		#else:
			#looking_object = active_puppets[index]
		# Old code below
		if active_puppets[index].puppet_class.fraction == 3 && \
		active_puppets[index].get_node_or_null("PlayerModel/Puppet/SafeZone") != null:
			looking_object = active_puppets[index].get_node("PlayerModel/Puppet/SafeZone")
		else:
			looking_object = active_puppets[index]
		
		if has_lookat_ik:
			get_parent().get_parent().get_node("RayCast3D").look_at(looking_object.global_position)
			puppet_node.get_node(armature_name + "/Skeleton3D/LookAtModifier3D").target_node = looking_object.get_path()
		elif active_puppets[index].puppet_class.fraction != 3:
			get_parent().get_parent().look_at(looking_object.global_position)
		looking_at_target = true
	elif looking_at_target:
		get_parent().get_parent().get_node("RayCast3D").rotation = Vector3.ZERO
		if has_lookat_ik:
			puppet_node.get_node(armature_name + "/Skeleton3D/LookAtModifier3D").target_node = ""
		looking_at_target = false
	
	# It handles watching at 173 and 650...
	if raycast != null && raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is MovableNpc:
			var puppet_class = collider.puppet_class
			if puppet_class.fraction == 2: # Need-to-look SCPs
				vision_entity.append(collider.get_node("PlayerModel/Puppet"))
				if !collider.get_node("PlayerModel/Puppet").watching_puppets.has(get_parent().get_parent()):
					collider.get_node("PlayerModel/Puppet").watching_puppets.append(get_parent().get_parent())
			elif vision_entity.size() > 0: # Release must-to-look SCPs
				for entity in vision_entity:
					entity.watching_puppets.clear()
				vision_entity.clear()
			_on_raycast_update_npc(collider.get_path())
		elif vision_entity.size() > 0:
			for entity in vision_entity:
				entity.watching_puppets.clear()
			vision_entity.clear()
	
	on_update_human(delta)

func on_update_human(delta: float):
	plugin_api_function("update")

func _on_raycast_update_npc(collider_path: String):
	pass

## Set animation to an entity via Animation Tree.
func set_state(animation_name: String, action_name: String, amount):
	puppet_node.get_node("AnimationTree").set("parameters/" + animation_name + "/" + action_name, amount)

#func set_anim_state(animation_name: String):
	#$AnimationPlayer.play(animation_name)

## Playing footsteps
func footstep(key: String):
	get_parent().get_parent().get_node("WalkSounds").stream = load(get_parent().get_parent().puppet_class.footstep_sounds[key][rng.randi_range(0, get_parent().get_parent().puppet_class.footstep_sounds[key].size() - 1)])
	get_parent().get_parent().get_node("WalkSounds").play()

## Hold item in hand
func hold_item(idx: int):
	if puppet_node.get_node_or_null(armature_name + "/Skeleton3D/ItemAttachment/Marker3D") != null:
		if get_parent().get_parent().is_player:
			if puppet_node.get_node(armature_name + "/Skeleton3D/ItemAttachment/Marker3D").get_child_count() > 0:
				for node in puppet_node.get_node(armature_name + "/Skeleton3D/ItemAttachment/Marker3D").get_children():
					node.queue_free()
				secondary_state = SecondaryState.NONE
				current_item = -1
			elif idx > 0 && idx < get_tree().root.get_node("Game").gamedata.items.size():
				secondary_state = SecondaryState.ITEM
				var item_prefab: Pickable = load(get_tree().root.get_node("Game").gamedata.items[idx].pickable_path).instantiate()
				item_prefab.picked = true
				item_prefab.freeze = true
				puppet_node.get_node(armature_name + "/Skeleton3D/ItemAttachment/Marker3D").add_child(item_prefab)
				current_item = idx
			

func effect_manager_start(effect: String, strength: float):
	match effect:
		"Scp686":
			if !resistance_scp686:
				#Achievement
				if Settings.setting_res.scp_study_progress_all.has("SCP-686"):
					if !Settings.setting_res.scp_study_progress_all["SCP-686"]:
						Settings.setting_res.scp_study_progress_all["SCP-686"] = true
						Settings.save_resource(Settings.setting_res)
				puppet_node.get_node(torso_node_path).mesh.surface_set_material(0, puppet_node.get_node(torso_node_path).mesh.surface_get_material(0).duplicate())
		"Scp178":
			if !resistance_scp178:
				if get_tree().get_node_count_in_group("Scp178-1") == 0 && !OS.has_feature("Lite"):
					#Achievement
					if Settings.setting_res.scp_study_progress_full.has("SCP-178"):
						if !Settings.setting_res.scp_study_progress_full["SCP-178"]:
							Settings.setting_res.scp_study_progress_full["SCP-178"] = true
							Settings.save_resource(Settings.setting_res)
					for i in range(64):
						var npc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
						npc.puppet_class = load("res://PlayerScript/PlayerClassResources/Optional/Scp178-1.tres")
						npc.position = NavigationServer3D.map_get_random_point(get_parent().get_parent().get_node("NavigationAgent3D").get_navigation_map(), 1, true)
						get_tree().root.get_node("Game/NPCs").add_child(npc)
				secondary_state = SecondaryState.HAT
				get_tree().root.get_node("Game/StaticPlayer/Head/Camera3D").set_cull_mask_value(20, true)
				var glasses: Pickable = load("res://InventorySystem/Items/ItemScp178.tscn").instantiate()
				glasses.picked = true
				glasses.freeze = true
				glasses.position = Vector3(0.0, 0.162, 0.215)
				glasses.rotation_degrees = Vector3(0.0, -90.0, 0.0)
				puppet_node.get_node(armature_name + "/Skeleton3D/HeadAttachment/Marker3D").add_child(glasses)
				await get_tree().create_timer(2.5).timeout
				secondary_state = SecondaryState.NONE
		"Scp067":
			if !get_parent().get_parent().get_node("UI/Inventory/Inventory").has_item(7):
				get_tree().root.get_node("Game").advanced_dialogue(["SCP067_CANT_USE"])
				await get_tree().create_timer(1.0).timeout
				get_parent().get_parent().get_node("StatusEffects").remove_status_effect(get_parent().get_parent().get_node("StatusEffects").get_status_effect_index("Scp067"))
				return
			scp_067_affected = true
			get_parent().get_parent().movement_freeze = true
			get_tree().root.get_node("Game").cutscene_anim()
			await get_tree().create_timer(3.0).timeout
			get_tree().root.get_node("Game").advanced_dialogue(["SCP067_DLG1"])
			await get_tree().create_timer(3.5).timeout
			get_tree().root.get_node("Game").advanced_dialogue(["SCP067_DLG2"])
			get_parent().get_parent().get_node("UI/Inventory/Inventory").item_remove_by_id(7, false)
			get_parent().get_parent().get_node("UI/Inventory/Inventory").add_item(13)
			await get_tree().create_timer(3.0).timeout
			get_tree().root.get_node("Game").advanced_dialogue(["SCP067_DLG3"])
			await get_tree().create_timer(1.0).timeout
			get_parent().get_parent().get_node("StatusEffects").remove_status_effect(get_parent().get_parent().get_node("StatusEffects").get_status_effect_index("Scp067"))
			if Settings.setting_res.scp_study_progress_all.has("SCP-067"):
				if !Settings.setting_res.scp_study_progress_all["SCP-067"]:
					Settings.setting_res.scp_study_progress_all["SCP-067"] = true
					Settings.save_resource(Settings.setting_res)
		"Scp2028":
			get_tree().root.get_node("Game").advanced_dialogue(["SCP2028_NIGHTMARE", "SCP2028_NIGHTMARE2", "SCP2028_NIGHTMARE3"])
			hold_item(20)
			if Settings.setting_res.scp_study_progress_all.has("SCP-2028"):
				if !Settings.setting_res.scp_study_progress_all["SCP-2028"]:
					Settings.setting_res.scp_study_progress_all["SCP-2028"] = true
					Settings.save_resource(Settings.setting_res)
	
	effect_manager_start_custom(effect, strength)

func effect_manager_start_custom(effect: String, strength: float):
	pass

func effect_manager_update(effect: String, strength: float):
	match effect:
		"Scp686":
			if !resistance_scp686:
				if puppet_node.get_node(torso_node_path).mesh.surface_get_material(0).get_shader_parameter("tint")[0] < 0.95:
					var value: float = get_physics_process_delta_time() * 2 * strength
					puppet_node.get_node(torso_node_path).mesh.surface_get_material(0).set_shader_parameter("tint", puppet_node.get_node(torso_node_path).mesh.surface_get_material(0).get_shader_parameter("tint") + Color(value, value, value))
				get_parent().get_parent().health_manage(-get_physics_process_delta_time() * strength, 2, "GAME_OVER_SCP_686")
		"Scp2075":
			effect_update_timer += get_physics_process_delta_time()
			if effect_update_timer > 6.3:
				var choice: int = rng.randi_range(0, 3)
				if choice == 3:
					if get_tree().get_first_node_in_group("Scp2075").get_parent() != null:
						if get_tree().get_first_node_in_group("Scp2075").get_parent().get_parent() != null:
							get_parent().get_parent().follow_target = get_tree().get_first_node_in_group("Scp2075").get_parent().get_parent().get_path()
							get_parent().get_parent().movement_freeze = true
				else:
					get_parent().get_parent().follow_target = ""
					get_parent().get_parent().movement_freeze = false
				effect_update_timer = 0.0
	effect_manager_update_custom(effect, strength)

func effect_manager_update_custom(effect: String, strength: float):
	pass

func effect_manager_destroy(effect: String, strength: float):
	match effect:
		"Scp178":
			if !resistance_scp178:
				get_tree().root.get_node("Game/StaticPlayer").apply_overlay("Scp178", 0.0)
				get_tree().root.get_node("Game/StaticPlayer/Head/Camera3D").set_cull_mask_value(20, false)
				for node in puppet_node.get_node(armature_name + "/Skeleton3D/HeadAttachment/Marker3D").get_children():
					node.queue_free()
		"Scp067":
			if scp_067_affected:
				get_parent().get_parent().movement_freeze = false
				get_tree().root.get_node("Game").cutscene_anim(true)
				get_tree().root.get_node("Game/FoundationTask").do_task("task_067")
			scp_067_affected = false
		"Scp2028":
			hold_item(-1)
	effect_manager_destroy_custom(effect, strength)

func effect_manager_destroy_custom(effect: String, strength: float):
	pass

## Follow the players, if cuffed
#func target_follow(delta: float):
	#if update_timer > 0:
		#update_timer -= delta
	#else:
		#for player in cuffed_players:
			#player.set_movement_target(get_parent().get_parent().global_position, true, false)
		#update_timer = 1.0

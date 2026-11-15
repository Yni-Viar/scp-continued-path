extends VisionScpPuppetScript
## SCP-173 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp173PuppetScript


@export var invincibility: bool = false
@export var blink_timer_default: float = 4.7
@export var is_blinking: bool = false
var blink_timer: float = blink_timer_default
var current_human: Node3D:
	set(val):
		if current_human == null: 
			if val != null:
				on_first_human_watches()
		elif val != null:
			if current_human.get_path() != val.get_path():
				on_human_watches()
		#elif current_human != null && val == null && !crunched_trigger:
			#on_human_leaves()
			#crunched_trigger = false
		current_human = val
		
var raycast: RayCast3D
var player_direction: Vector3
var movement_reset: bool = false
var crunched_trigger: bool = false

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	raycast = get_parent().get_parent().get_node("RayCastLow")
	#get_parent().get_parent().get_node("ActionArea").connect("body_entered", on_action_area_body_entered)
	#get_parent().get_parent().get_node("ActionArea").connect("body_exited", on_action_area_body_exited)
	#set_face()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	scp_173_blink(delta)
	# If is watching, set velocity to zero, else - go to player.
	if ((is_blinking && watching_puppets.size() > 0 && current_human != null) || (watching_puppets.size() == 0 && current_human != null)) && !freeze:
		scp_173_movement()
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider is MovableNpc:
				if collider.fraction == 0 && collider.puppet_class.team < 2048:
					# little SL easter egg
					get_parent().get_parent().get_node("InteractSound").stream = \
					 load("res://Sounds/Character/Scp173/SCPSL/173_Hume_Shield_Break.ogg") if rng.randi_range(0, 15) == 15 else \
					 load("res://Sounds/Character/Scp173/DNesov/NeckSnap.ogg")
					get_parent().get_parent().get_node("InteractSound").play()
					collider.health_manage(-16777216, 0, "GAME_OVER_SCP_173")
					crunched_trigger = true
					active_puppets.erase(current_human)
					current_human = null
					movement_reset = false
## Blink mechanic
func scp_173_blink(delta: float):
	# If blink timer > 0 - then wait
	if blink_timer > 0:
		blink_timer -= delta
	elif !freeze:
		is_blinking = true
		movement_reset = false
		# Navigate to the human near you
		if active_puppets.size() > 0:
			if !active_puppets.has(current_human):
				current_human = active_puppets[rng.randi_range(0, active_puppets.size() - 1)]
		else:
			if current_human != null:
				on_human_leaves()
			current_human = null
		
		#Achievement
		if Settings.setting_res.scp_study_progress_all.has("SCP-173"):
			if !Settings.setting_res.scp_study_progress_all["SCP-173"]:
				Settings.setting_res.scp_study_progress_all["SCP-173"] = true
				Settings.save_resource(Settings.setting_res)
		blink_timer = blink_timer_default
		await get_tree().create_timer(0.3).timeout
		is_blinking = false
## Movement control
func scp_173_movement():
	if state == States.IDLE && !movement_reset:
		get_parent().get_parent().set_target_position(current_human.global_position)# + current_human.global_transform.basis.z * 1.5)
		get_parent().get_parent().get_node("WalkSounds").stream = load(get_parent().get_parent().puppet_class.footstep_sounds["run"][rng.randi_range(0, get_parent().get_parent().puppet_class.footstep_sounds["run"].size() - 1)])
		get_parent().get_parent().get_node("WalkSounds").play()
		movement_reset = true

#func on_action_area_body_exited(body: Node3D):
	#pass


func _on_scp_173_spawner_item_not_found() -> void:
	get_parent().get_parent().health_manage(-16777216)

## Plays trigger sound
func on_first_human_watches() -> void:
	get_parent().get_parent().get_node("InteractSound").stream = load("res://Sounds/Character/Scp173/SCPSL/173_Encounter.ogg")
	get_parent().get_parent().get_node("InteractSound").play()

## Plays trigger sound
func on_human_watches() -> void:
	get_parent().get_parent().get_node("InteractSound").stream = load("res://Sounds/Character/Scp173/SCPSL/173_Its_Still_Here_Ambient.ogg")
	get_parent().get_parent().get_node("InteractSound").play()

func on_human_leaves() -> void:
	get_parent().get_parent().get_node("InteractSound").stream = load("res://Sounds/Character/Scp173/SCPSL/173_Its_Gone_Ambient.ogg")
	get_parent().get_parent().get_node("InteractSound").play()

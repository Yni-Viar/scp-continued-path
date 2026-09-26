extends Node3D
## Static player
## Made by Yni, licensed under MIT License.
class_name StaticPlayer

enum CameraMode {ALL, UPPERLOOK, THIRD_PERSON, SIZE}

@export var camera_mode: CameraMode = CameraMode.ALL:
	set(val):
		if val != CameraMode.ALL:
			if current_camera_mode != val:
				preset_toggle_onstart(val)
		camera_mode = val 
@export var current_camera_mode: CameraMode = CameraMode.UPPERLOOK
@export var target_puppet_path: String = ""
#Fixes keyboard animation glitch
@export var walk_cooldown: int = 1
var mouse_sensitivity = 0.03125
var prev_x_coordinate: float = 0
var scroll_factor: float = 1.0
var transition: NodePath

# Used for keyboard navigation
var target_keyboard_position: float = 0.0
#Fixes keyboard animation glitch
var walk_timer: int = 0

const RAY_LENGTH = 512

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Head/Camera3D.current = true
	# OpenGL Compatibility renderer supports SSAO since Godot 4.6
	# As for May 2026, we stay on 4.5 just because it is the most stable\
	# Godot release.
	#if Settings.setting_res.ssao && (RenderingServer.get_current_rendering_method() == "mobile" || \
	 #(RenderingServer.get_current_rendering_method() == "gl_compatibility" && \
	  #Engine.get_version_info()["minor"] < 6)):
		## No longer used, since we updated to Godot 4.7
		#$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("look"):
			rotate_player(event)
	if event is InputEventScreenDrag:
		rotate_player(event)
	#if event.is_action_pressed("scroll_up"):
		#scroll_factor += 0.125
		#scroll_factor = clamp(scroll_factor, 1.0, 8.0)
		#$Head/Camera3D.fov = 75.0 / scroll_factor
	#if event.is_action_pressed("scroll_down"):
		#scroll_factor -= 0.125
		#scroll_factor = clamp(scroll_factor, 1.0, 8.0)
		#$Head/Camera3D.fov = 75.0 / scroll_factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#Handle smooth camera transitions
	if transition != null && !transition.is_empty():
		var to_pos: Vector3 = get_node(transition).position
		$Head/Camera3D.position = $Head/Camera3D.position.move_toward(to_pos, 12 * delta)
		if $Head/Camera3D.position.is_equal_approx(to_pos):
			transition = NodePath()
	if Input.is_action_just_pressed("toggle_mode"):
		toggle_switcher()
	target_keyboard_position = Input.get_axis("move_forward", "move_backward")
	
	rotate_player_by_key(Vector2i(int(Input.is_action_just_pressed("camera_rotate_right")) - int(Input.is_action_just_pressed("camera_rotate_left")), 0))
	if !target_puppet_path.is_empty():
		if get_node_or_null(target_puppet_path) == null:
			get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_DIE")
			set_physics_process(false)
		else:
			get_tree().root.get_node("Game/UI/HealthBar").value = get_node(target_puppet_path).current_health[0]
			if get_node(target_puppet_path).fraction == 0:
				get_tree().root.get_node("Game/UI/ThirstBar").value = get_node(target_puppet_path).current_health[2]
				get_tree().root.get_node("Game/UI/HungerBar").value = get_node(target_puppet_path).current_health[3]
			# Apply bonus to Y coordinate if current_camera_mode is third person
			if current_camera_mode == CameraMode.THIRD_PERSON:
				global_position = get_node(target_puppet_path).global_position + Vector3(0, 2.5, 0)
			else:
				global_position = get_node(target_puppet_path).global_position + Vector3(0, 3, 0)
	if !is_zero_approx(target_keyboard_position):
		interact("InputMove")

## Used from Godot Docs
func intersect() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = $Head/Camera3D.project_ray_origin(mousepos)
	var end = origin + $Head/Camera3D.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	return space_state.intersect_ray(query)

## Used from Godot Docs
func intersect_shape(intersect_position: Vector3) -> Array[Dictionary]:
	var space_state = get_world_3d().direct_space_state
	
	var shape_rid = PhysicsServer3D.sphere_shape_create()
	var radius = 3.0
	PhysicsServer3D.shape_set_data(shape_rid, radius)

	var params = PhysicsShapeQueryParameters3D.new()
	params.shape_rid = shape_rid
	params.transform = Transform3D(Basis(), intersect_position)
	params.collision_mask = 10
	
	var result: Array[Dictionary] = space_state.intersect_shape(params, 4)
	
	# Release the shape when done with physics queries.
	PhysicsServer3D.free_rid(shape_rid)
	
	return result

## Main interacting function.
func interact(value: String) -> void:
	if get_node_or_null(target_puppet_path) == null:
		get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_DIE")
	else:
		match value:
			"Point":
				var result: Dictionary = intersect()
				if result.keys().size() > 0 && !(get_node(target_puppet_path).movement_freeze || get_node(target_puppet_path).platform_moving):
					# Shape cast for items
					var shape_result: Array[Dictionary] = intersect_shape(result["position"])
					for s_result in shape_result:
						if s_result.keys().size() > 0:
							#Item detected
							if s_result["collider"] is Pickable && !s_result["collider"].picked &&\
							 !s_result["collider"].freeze && s_result["collider"].global_position.distance_to(get_node(target_puppet_path).global_position) < 4.0:
								# Pick up item
								if s_result["collider"].get("item") != null:
									get_node(target_puppet_path + "/UI/Inventory/Inventory").add_item_with_state(s_result["collider"].item)
								else:
									get_node(target_puppet_path + "/UI/Inventory/Inventory").add_item(s_result["collider"].item_id)
								# Prevent dupe
								s_result["collider"].picked = true
								# If ItemManager exist, call removed trigger
								if get_tree().root.get_node("Game/Items") is ItemManager:
									get_tree().root.get_node("Game/Items")._item_removed(s_result["collider"].get_path())
								# Remove picked prefab
								s_result["collider"].queue_free()
								#Use only one item
								break
							# Static interactable detected.
							if s_result["collider"] is InteractableStatic && s_result["collider"].global_position.distance_to(get_node(target_puppet_path).global_position) < 4.0:
								s_result["collider"].interact(get_node(target_puppet_path))
								#Use only one interactable
								break
							if s_result["collider"] is InteractableRigid && s_result["collider"].global_position.distance_to(get_node(target_puppet_path).global_position) < 4.0:
								s_result["collider"].interact(get_node(target_puppet_path))
								#Use only one interactable
								break
							# Player detected
							if s_result["collider"] is MovableNpc:
								if !s_result["collider"].is_player:
									match s_result["collider"].puppet_class.interacting_action:
										1:  # FOLLOW
											s_result["collider"].follow_target = target_puppet_path
											s_result["collider"].wandering_system = MovableNpc.WanderingSystem.NONE
										2: # SPECIAL
											if s_result["collider"].get_node_or_null("PlayerModel/Puppet") != null:
												if s_result["collider"].get_node("PlayerModel/Puppet") is BasePuppetScript:
													s_result["collider"].get_node("PlayerModel/Puppet").special_action()
					# ray cast for moving
					if get_node_or_null(target_puppet_path) == null:
						get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_DIE")
					else:
						get_node(target_puppet_path).set_target_position(result["position"])
			"InputMove":
				if walk_timer == walk_cooldown:
					if get_node_or_null(target_puppet_path) == null:
						get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_DIE")
					else:
						get_node(target_puppet_path).set_target_position(get_node(target_puppet_path).global_position + $Waypoint.global_transform.basis.z * 2 * target_keyboard_position)
					walk_timer = 0
				else:
					walk_timer += 1

func rotate_player(event: InputEvent):
	# Yni: Necessary to fix annoying bug on Android, when if you rotate screen, player began to move.
	# https://kidscancode.org/godot_recipes/3.x/3d/camera_gimbal/index.html
	rotate_object_local(Vector3.UP, event.relative.x * mouse_sensitivity * 0.05)
	var y_rotation = clamp(event.relative.y, -30, 30)
	$Head.rotate_object_local(Vector3.RIGHT, y_rotation * mouse_sensitivity * 0.05)
	$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x, -90, 0)
	$Waypoint.rotation = $Head.rotation
	#rotation.y -= event.relative.x * mouse_sensitivity * 0.05
	#rotation.x -= event.relative.y * mouse_sensitivity * 0.05
	#rotation_degrees.y = clamp(rotation_degrees.y, -90, 90)

func rotate_player_by_key(direction: Vector2i):
	var x_dir: float
	var y_dir: float
	match direction:
		Vector2i.UP:
			y_dir = 15
		Vector2i.DOWN:
			y_dir = -15
		Vector2i.LEFT:
			x_dir = -45
		Vector2i.RIGHT:
			x_dir = 45
	# Yni: Necessary to fix annoying bug on Android, when if you rotate screen, player began to move.
	# https://kidscancode.org/godot_recipes/3.x/3d/camera_gimbal/index.html
	rotate_object_local(Vector3.UP, deg_to_rad(x_dir))
	var y_rotation = clamp(y_dir, -30, 30)
	$Head.rotate_object_local(Vector3.RIGHT, deg_to_rad(y_rotation))
	$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x, -90, 0)

## Automatic toggle camera mode.
func toggle_switcher():
	toggle_mode(current_camera_mode + 1 if current_camera_mode + 1 < CameraMode.SIZE else 1)

## Used when using fixed camera_mode to auto-toggle camera to camera_mode value.
## For example if CameraMode is THIRD_PERSON, camera will auto-toggled to that mode.
## Used from Hikkan.
func preset_toggle_onstart(val: CameraMode):
	call_deferred("toggle_mode", val)

## Toggle camera mode backend.
func toggle_mode(mode: int):
	if mode == 0 || mode >= CameraMode.SIZE:
		printerr("Cannot specify incompatible mode")
	match mode:
		1:
			if camera_mode == 0 || camera_mode == 1:
				transition = $Head/UpperLook.get_path()
				current_camera_mode = CameraMode.UPPERLOOK
			else:
				printerr("camera_mode does not allow this mode")
		2:
			if camera_mode == 0 || camera_mode == 2:
				transition = $Head/ThirdPerson.get_path()
				current_camera_mode = CameraMode.THIRD_PERSON
			else:
				printerr("camera_mode does not allow this mode")

func _on_optimizator_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		body.optimizator_paused = false
	elif body is RigidBody3D:
		if body is Pickable:
			if body.picked:
				return
		body.freeze = false


func _on_optimizator_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		body.optimizator_paused = true
	elif body is RigidBody3D:
		if body is Pickable:
			if body.picked:
				return
		body.freeze = true

## Applies overlay to player.
func apply_overlay(effect: String, strength: float):
	match effect:
		"Frozen":
			if strength > 0.03125:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Cold")
				$Head/Camera3D/Overlays/TintCompositor.apply_strength("Cold", strength)
			else:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Cold", true)
		"EdgeVision":
			if strength >= 0.375:
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(0)
			else:
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(0, true)
		"Scp178":
			if strength >= 0.375:
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(4)
			else:
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(4, true)
		"Amnesia":
			if strength >= 0.375:
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(2)
			else:
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(2, true)
		"Electrocuted":
			if strength >= 0.375:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Electrocute")
			else:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Electrocute", true)
		"Scp2028":
			if strength >= 0.375:
				#Achievement
				if Settings.setting_res.scp_study_progress_all.has("SCP-2028"):
					if !Settings.setting_res.scp_study_progress_all["SCP-2028"]:
						Settings.setting_res.scp_study_progress_all["SCP-2028"] = true
						Settings.save_resource(Settings.setting_res)
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(3)
			else:
				$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(3, true)
		"Scp261Orange":
			if strength >= 0.375:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Scp261Orange")
			else:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Scp261Orange", true)
		"Scp261KleinBottle":
			if strength >= 0.375:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Scp261KleinBottle")
			else:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Scp261KleinBottle", true)
		"Fatigue":
			if strength > 0.984375:
				get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_ASLEEP")
			if strength > 0.03125:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Fatigue")
				$Head/Camera3D/Overlays/TintCompositor.apply_strength("Fatigue", strength)
			else:
				$Head/Camera3D/Overlays/TintCompositor.apply_shader("Fatigue", true)
		"FeyWorld":
			$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(5)
		_:
			printerr("Since v8.0.0, GDShader and Tint compositors replaced legacy shader system.")

func overlay_system():
	pass

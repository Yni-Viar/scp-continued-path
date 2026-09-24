extends SkinnablePuppetScript
## Plugin-based puppet script
## Made by Yni, licensed under MIT license.
class_name CustomPuppetScript

## Trigger type
enum TriggerShape {SPHERE = 0, BOX = 1, CAPSULE = 2, CYLINDER = 3}

@export var custom_global_vars: Dictionary[String, Variant] = {}

## Trigger path. If trigger does not exist, there is empty string
var trigger: NodePath = ""

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	gompl.register_func("spawn_trigger", spawn_trigger)
	
	gompl.register_func("get_distance_to_player", get_distance_to_player)
	gompl.register_func("get_follow", get_follow)
	gompl.register_func("set_follow", set_follow)
	gompl.register_func("get_front_facing", get_front_facing)
	gompl.register_func("get_global_pos", get_global_pos)
	gompl.register_func("set_global_pos", set_global_pos)
	gompl.register_func("set_global_posv", set_global_posv)
	gompl.register_func("get_global_rot", get_global_rot)
	gompl.register_func("set_global_rot", set_global_rot)
	gompl.register_func("set_global_rotv", set_global_rotv)
	gompl.register_func("get_immortal", get_immortal)
	gompl.register_func("set_immortal", set_immortal)
	gompl.register_func("get_movement_freeze", get_movement_freeze)
	gompl.register_func("set_movement_freeze", set_movement_freeze)
	gompl.register_func("get_player_front_facing", get_player_front_facing)
	gompl.register_func("get_player_global_pos", get_player_global_position)
	
	gompl.register_func("add_item", add_item)
	gompl.register_func("player_add_item", player_add_item)
	gompl.register_func("interaction_sound", interaction_sound)
	gompl.register_func("health_manage", health_manage)
	gompl.register_func("player_health_manage", player_health_manage)
	gompl.register_func("remove_item", remove_item)
	gompl.register_func("player_remove_item", player_remove_item)
	gompl.register_func("player_get_all_items", player_get_all_items)
	gompl.register_func("go_to_target", go_to_target)
	gompl.register_func("player_set_status_effect", player_set_status_effect)
	gompl.register_func("despawn", despawn)
	plugin_api_function("start", custom_global_vars)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	plugin_api_function("update", custom_global_vars)

func action_1() -> void:
	plugin_api_function("custom_action_1", custom_global_vars)

func action_2() -> void:
	plugin_api_function("custom_action_2", custom_global_vars)

func action_3() -> void:
	plugin_api_function("custom_action_3", custom_global_vars)

func action_4() -> void:
	plugin_api_function("custom_action_4", custom_global_vars)

## Creates trigger, if it does not exist
func spawn_trigger(shape: TriggerShape, size: float, collider_rotation_x: float = 0, collider_rotation_y: float = 0, collider_rotation_z: float = 0, position_from_center_x: float = 0, position_from_center_y: float = 0, position_from_center_z: float = 0, height: float = 1.0) -> void:
	if trigger == null:
		Console.print_error("[Plugin system] Triggers are disabled for this puppet.", true)
		return
	if !trigger.is_empty():
		Console.print_error("[Plugin system] Trigger already created! Currently, only one trigger per class is supported")
		return
	var area_3d: Area3D = Area3D.new()
	area_3d.collision_layer = 15
	area_3d.collision_mask = 15
	add_child(area_3d)
	area_3d.position = Vector3(position_from_center_x, position_from_center_y, position_from_center_z)
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	match shape:
		TriggerShape.SPHERE:
			collision_shape.shape = SphereShape3D.new()
			collision_shape.shape.radius = size
		TriggerShape.BOX:
			collision_shape.shape = BoxShape3D.new()
			collision_shape.shape.size = Vector3(size, size, size)
		TriggerShape.CAPSULE:
			collision_shape.shape = CapsuleShape3D.new()
			collision_shape.shape.radius = size
			collision_shape.shape.height = height
		TriggerShape.CYLINDER:
			collision_shape.shape = CylinderShape3D.new()
			collision_shape.shape.radius = size
			collision_shape.shape.height = height
	collision_shape.rotation = Vector3(collider_rotation_x, collider_rotation_y, collider_rotation_z)
	area_3d.add_child(collision_shape)
	area_3d.body_entered.connect(_on_trigger_body_entered)
	area_3d.body_exited.connect(_on_trigger_body_exited)

func _on_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			plugin_api_function("player_entered_trigger", custom_global_vars)
		else:
			plugin_api_function("puppet_entered_trigger", custom_global_vars)

func _on_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			plugin_api_function("player_exited_trigger", custom_global_vars)
		else:
			plugin_api_function("puppet_exited_trigger", custom_global_vars)

func on_vision_area_body_entered(body: Node3D):
	if body is MovableNpc:
		for puppet_class in vision_class_detect:
			if body.fraction == puppet_class:
				active_puppets.append(body)
				plugin_api_function("player_entered_vision_area", custom_global_vars)

func on_vision_area_body_exited(body: Node3D):
	if body is MovableNpc:
		if active_puppets.has(body):
			active_puppets.erase(body)
			plugin_api_function("player_exited_vision_area", custom_global_vars)

func special_action():
	plugin_api_function("special_action", custom_global_vars)



### Plugin API

func get_distance_to_player() -> void:
	if get_tree().root.get_node("Game").protagonist != null:
		custom_global_vars["builtin_distance_to_player"] = get_parent().get_parent().global_position.distance_to(get_tree().root.get_node("Game").protagonist.global_position)

func get_player_front_facing() -> void:
	if get_tree().root.get_node("Game").protagonist != null:
		custom_global_vars["builtin_player_front_facing"] = get_tree().root.get_node("Game").protagonist.global_transform.basis.z

func get_front_facing() -> void:
	custom_global_vars["builtin_front_facing"] = get_parent().get_parent().global_transform.basis.z

func get_player_global_position() -> void:
	if get_tree().root.get_node("Game").protagonist != null:
		custom_global_vars["builtin_player_global_pos"] = get_tree().root.get_node("Game").protagonist.global_position

func get_global_pos() -> void:
	custom_global_vars["builtin_global_pos"] = get_parent().get_parent().global_position

func set_global_pos(x: float, y: float, z: float) -> void:
	get_parent().get_parent().global_position = Vector3(x, y, z)

func set_global_posv(pos: Vector3) -> void:
	get_parent().get_parent().global_position = pos

func get_global_rot(in_degrees: bool) -> void:
	if in_degrees:
		custom_global_vars["builtin_global_rot"] = get_parent().get_parent().global_rotation_degrees
	else:
		custom_global_vars["builtin_global_rot"] = get_parent().get_parent().global_rotation

func set_global_rot(in_degrees: bool, x: float, y: float, z: float) -> void:
	if in_degrees:
		get_parent().get_parent().global_rotation_degrees = Vector3(x, y, z)
	else:
		get_parent().get_parent().global_rotation = Vector3(x, y, z)

func set_global_rotv(in_degrees: bool, rot: Vector3) -> void:
	if in_degrees:
		get_parent().get_parent().global_rotation_degrees = rot
	else:
		get_parent().get_parent().global_rotation = rot

func get_follow() -> void:
	custom_global_vars["builtin_follow"] = get_parent().get_parent().follow_target

func set_follow(path: String) -> void:
	get_parent().get_parent().follow_target = path

func get_immortal() -> void:
	custom_global_vars["builtin_immortal"] = get_parent().get_parent().immortal

func set_immortal(value: bool) -> void:
	get_parent().get_parent().immortal = value

func get_movement_freeze() -> void:
	custom_global_vars["builtin_movement_freeze"] = get_parent().get_parent().movement_freeze

func set_movement_freeze(value: bool) -> void:
	get_parent().get_parent().movement_freeze = value

func player_health_manage(health_to_add: float, health_type: int = 0, deplete_reason: String = "") -> void:
	if get_tree().root.get_node("Game").protagonist != null:
		get_tree().root.get_node("Game").protagonist.health_manage(health_to_add, health_type, deplete_reason)

func health_manage(health_to_add: float, health_type: int = 0, deplete_reason: String = "") -> void:
	get_parent().get_parent().health_manage(health_to_add, health_type, deplete_reason)

func add_item(item_id: int) -> void:
	get_parent().get_parent().get_node("UI/Inventory/Inventory").add_item(item_id)

func remove_item(item_id: int, drop: bool = false) -> void:
	get_parent().get_parent().get_node("UI/Inventory/Inventory").item_remove_by_id(item_id, drop)

func player_add_item(item_id: int) -> void:
	if get_tree().root.get_node("Game").protagonist != null:
		get_tree().root.get_node("Game").protagonist.get_node("UI/Inventory/Inventory").add_item(item_id)

func player_remove_item(item_id: int, drop: bool = false) -> void:
	if get_tree().root.get_node("Game").protagonist != null:
		get_tree().root.get_node("Game").protagonist.get_node("UI/Inventory/Inventory").item_remove_by_id(item_id, drop)

func interaction_sound(sound_path: String) -> void:
	var full_path: String = "user://mods/puppets/custom/".path_join(gltf_path_to_find).path_join("sounds").path_join(sound_path)
	if FileAccess.file_exists(full_path):
		var resource: Resource = load(full_path)
		if resource is AudioStream:
			get_parent().get_parent().get_node("InteractSound").stream = load(full_path)
			get_parent().get_parent().get_node("InteractSound").play()

func player_get_all_items():
	if get_tree().root.get_node("Game").protagonist != null:
		var item_array: Array[Item] = get_tree().root.get_node("Game").protagonist.get_node("UI/Inventory/Inventory").get_all_items()
		var result_array: Array[int] = []
		result_array.resize(item_array.size())
		for i in range(item_array.size()):
			result_array[i] = item_array[i].id
		custom_global_vars["builtin_player_items"] = result_array

func go_to_target(primary_target: String):
	if get_parent().get_parent().platform_moving:
		return
	get_parent().get_parent().follow_target = primary_target
	await get_tree().create_timer(0.5).timeout
	if !get_parent().get_parent().get_node("NavigationAgent3D").is_target_reachable():
		get_parent().get_parent().follow_target = get_tree().get_nodes_in_group("WavePointUpper")[rng.randi_range(0, get_tree().get_node_count_in_group("WavePointUpper") - 1)].get_path()
		if !get_parent().get_parent().get_node("NavigationAgent3D").is_target_reachable():
			get_parent().get_parent().follow_target = get_tree().get_nodes_in_group("WavePointLower")[rng.randi_range(0, get_tree().get_node_count_in_group("WavePointLower") - 1)].get_path()

func player_set_status_effect(effect: String, strength: float, duration: float):
	if get_tree().root.get_node("Game").protagonist != null:
		if effect == "Frozen":
			write_line("You cannot set Frozen status effect directly. Please, use player_health_manage(health_to_add: float, 1) for setting this status effect")
			return
		get_tree().root.get_node("Game").protagonist.get_node("StatusEffects").apply_status_effect(effect, strength, duration)

func despawn() -> void:
	get_parent().get_parent().queue_free()

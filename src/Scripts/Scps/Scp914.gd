extends StaticBody3D
## SCP-914 code
## Actually, this is one of my oldest code, I made this system in Q4 2022.
## Before SCP: Site Online, and any map generator ports for Godot existed...
## I converted Virtual's map generator for Godot in January 2023.
## This code was used in Site Online, but eventually, in 2025 it met a new home - 
## SCP: Continued Path.
##
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp914

enum Scp914Mode {ROUGH, COARSE, ONE_TO_ONE, FINE, VERY_FINE}

var items_to_refine: Array[Pickable] = []
#var players_to_refine: Array[MovableNpc] = []
var refining: bool = false
var door_block_node_type: int = -1
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var mode: Scp914Mode = Scp914Mode.ONE_TO_ONE

@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var door_block_in: Node3D = $DoorBlockIn
@onready var door_block_out: Node3D = $DoorBlockOut

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if door_block_in is NavigationLink3D && door_block_out is NavigationLink3D:
		door_block_node_type = 1
	elif door_block_in is CollisionShape3D && door_block_out is CollisionShape3D:
		door_block_node_type = 0

## Main SCP-914 function.
func refine():
	#Close doors.
	match door_block_node_type:
		0:
			door_block_in.disabled = false
			door_block_out.disabled = false
		1:
			door_block_in.enabled = false
			door_block_out.enabled = false
	anim_player.stop()
	anim_player.play("Armature|Armature|Armature|Armature|Event|Armature|Event|Armatu")
	await get_tree().create_timer(6.0).timeout
	for item in items_to_refine:
		var target_id: int = -1
		# Parse items
		match mode:
			Scp914Mode.ROUGH:
				if get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_rough.size() > 0:
					target_id = get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_rough[rng.randi_range(0, get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_rough.size() - 1)]
			Scp914Mode.COARSE:
				if get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_coarse.size() > 0:
					target_id = get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_coarse[rng.randi_range(0, get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_coarse.size() - 1)]
			Scp914Mode.ONE_TO_ONE:
				if get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_one_to_one.size() > 0:
					target_id = get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_one_to_one[rng.randi_range(0, get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_one_to_one.size() - 1)]
			Scp914Mode.FINE:
				if get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_fine.size() > 0:
					target_id = get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_fine[rng.randi_range(0, get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_fine.size() - 1)]
			Scp914Mode.VERY_FINE:
				if get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_very_fine.size() > 0:
					target_id = get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_very_fine[rng.randi_range(0, get_tree().root.get_node("Game").gamedata.items[item.item_id].upgrade_very_fine.size() - 1)]
		# If resulting index > 0 - return new item, else remove it.
		if target_id >= 0:
			var result_item: Pickable = load(get_tree().root.get_node("Game").gamedata.items[target_id].pickable_path).instantiate()
			result_item.position = $OutputSpawner.global_position
			get_tree().root.get_node("Game/Items").add_child(result_item)
		item.queue_free()
	await get_tree().create_timer(6.0).timeout
	# Open doors
	match door_block_node_type:
		0:
			door_block_in.disabled = true
			door_block_out.disabled = true
		1:
			door_block_in.enabled = true
			door_block_out.enabled = true
	# Achievement
	if Settings.setting_res.scp_study_progress_full.has("SCP-914"):
		if !Settings.setting_res.scp_study_progress_full["SCP-914"]:
			Settings.setting_res.scp_study_progress_full["SCP-914"] = true
			Settings.save_resource(Settings.setting_res)


func _on_add_items_area_body_entered(body: Node3D) -> void:
	if body is Pickable:
		items_to_refine.append(body)


func _on_add_items_area_body_exited(body: Node3D) -> void:
	if body is Pickable:
		items_to_refine.erase(body)

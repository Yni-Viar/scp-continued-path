extends SkinnableHumanPuppetScript
## SCP-347 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp347PuppetScript

var blink_timer: float = 0.0
## Shows or hides infrared scan of SCP-347
var infrared_visibility: bool = false:
	set(val):
		infrared_visibility = val
		puppet_node.get_node(armature_name).visible = infrared_visibility

# Called when the node enters the scene tree for the first time.
#func on_start_human() -> void:
	#super.on_start_human()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_update_human(delta: float) -> void:
	scp_347_infrared_blink(delta)

## Shows for 8 seconds 347 position
func scp_347_infrared_blink(delta: float):
	if blink_timer > 0:
		blink_timer -= delta
	elif !infrared_visibility:
		infrared_visibility = true
		await get_tree().create_timer(0.5).timeout
		infrared_visibility = false
		blink_timer = 8.0


func _on_achievement_screen_entered() -> void:
	#Achievement
	if Settings.setting_res.scp_study_progress_all.has("SCP-347"):
		if !Settings.setting_res.scp_study_progress_all["SCP-347"]:
			Settings.setting_res.scp_study_progress_all["SCP-347"] = true
			Settings.save_resource(Settings.setting_res)

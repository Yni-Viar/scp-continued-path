extends SkinnableHumanPuppetScript
## SCP-2075 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

const CONTROL_THRESHOLD: int = 2

var bodies_to_control: Array[NodePath] = []
var control_counter: int = 0

func _on_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			bodies_to_control.append(body.get_path())

func _on_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc && bodies_to_control.has(body.get_path()):
		bodies_to_control.append(body.get_path())

func special_action():
	if control_counter < CONTROL_THRESHOLD:
		control_counter += 1
	else:
		for body in bodies_to_control:
			if get_node(str(body) + "/StatusEffects").get_status_effect_index("Scp2075") == -1:
				get_node(str(body) + "/StatusEffects").apply_status_effect("Scp2075", 1.0, 0.0)

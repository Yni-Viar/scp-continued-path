extends Area3D
## Switches environment
## Made by Yni, licensed under MIT License.
class_name EnvironmentTrigger
## Must be file name WITHOUT path, _HQ/_LQ postfixes and extensions (like ".tres")
## Only needs env name from res://Assets/Environment/ folder
@export var env_name: String


func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			if env_name == null || env_name.is_empty():
				printerr("Environment not specified")
				return
			if OS.get_name() != "Web" && OS.get_name() != "Android":
				apply_environment(load("res://Assets/Environment/" + env_name + "_HQ.tres"))
			else:
				apply_environment(load("res://Assets/Environment/" + env_name + "_LQ.tres"))

func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			apply_environment(load("res://Assets/Environment/Default.tres"), true)

func apply_environment(environment: Environment, default_background: bool = false):
	get_tree().root.get_node("Game/WorldEnvironment").environment = environment
	get_tree().root.get_node("Game/WorldEnvironment").environment.glow_enabled = Settings.setting_res.glow
	# Enable SSAO in OpenGL only in Godot 4.6
	if RenderingServer.get_current_rendering_method() == "forward_plus" || \
	 RenderingServer.get_current_rendering_method() == "gl_compatibility":
		get_tree().root.get_node("Game/WorldEnvironment").environment.ssao_enabled = Settings.setting_res.ssao
	get_tree().root.get_node("Game/WorldEnvironment").environment.tonemap_mode = Settings.setting_res.tonemapper
	if Settings.setting_res.tonemapper != Environment.TONE_MAPPER_LINEAR || \
	 Settings.setting_res.tonemapper != Environment.TONE_MAPPER_AGX:
		get_tree().root.get_node("Game/WorldEnvironment").environment.tonemap_white = 2.0
	else:
		get_tree().root.get_node("Game/WorldEnvironment").environment.tonemap_white = 1.0
	
	if Settings.setting_res.lighting == SettingsResource.Lighting.NONE:
		get_tree().root.get_node("Game/WorldEnvironment").environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		get_tree().root.get_node("Game/WorldEnvironment").environment.ambient_light_color = Color(0.5, 0.5, 0.5)
	else:
		get_tree().root.get_node("Game/WorldEnvironment").environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY if !default_background else Environment.AMBIENT_SOURCE_COLOR

extends Node3D
class_name GameCore
## Game system.
## Made by Yni, licensed under MIT license.

signal round_started

@export var gamedata: GameData

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Presets for game ##
var map_seed: int = -1
## Current hours (is set by Surface Zone)
var hours: int = 8
## Current minutes (is set by Surface Zone)
var minutes: int = 0
## End presets for game ##

var mtf_cooldown: float = 35.0
## Protagonist tracker
var protagonist: MovableNpc
## Map seed public name
var map_seed_name: String = ""
## Check if the game was finished
var game_ended: bool = false


var showable_res: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.viewport_set_measure_render_time(get_tree().root.get_viewport_rid(), true)
	$StaticPlayer.set_physics_process(false)
	if OS.has_feature("Lite"):
		gamedata = load("res://Scripts/GameData/Lite/LiteGame.tres")
		var rooms: Array[MapGenZone] = [load("res://MapGen/Lite/MaintenanceZoneLite.tres"), \
		  load("res://MapGen/Lite/StorageZoneLite.tres"), \
		  load("res://MapGen/Lite/ResearchZoneLite.tres"), \
		  load("res://MapGen/Lite/PersonnelZoneLite.tres")]
		#if map_seed_name.containsn("scpsl") && ResourceLoader.exists("res://MapGen/Lite/SLFeature/StorageZoneLite.tres"):
			#rooms = [load("res://MapGen/Lite/MaintenanceZoneLite.tres"), \
			  #load("res://MapGen/Lite/SLFeature/StorageZoneLite.tres"), \
			  #load("res://MapGen/Lite/ResearchZoneLite.tres"), \
			  #load("res://MapGen/Lite/PersonnelZoneLite.tres")]
		$FacilityGenerator.rooms = rooms
		
	else:
		gamedata = load("res://Scripts/GameData/Optional/DefaultGame.tres")
		var rooms: Array[MapGenZone] = [load("res://MapGen/Optional/MaintenanceZone.tres"), 
		   load("res://MapGen/Optional/StorageZone.tres"), 
		   load("res://MapGen/Optional/ResearchZone.tres"), 
		   load("res://MapGen/Optional/PersonnelZone.tres")]
		#if map_seed_name.containsn("scpsl") && ResourceLoader.exists("res://MapGen/Optional/SLFeature/StorageZone.tres"):
			#rooms = [load("res://MapGen/Optional/MaintenanceZone.tres"), 
		   #load("res://MapGen/Optional/SLFeature/StorageZone.tres"), 
		   #load("res://MapGen/Optional/ResearchZone.tres"), 
		   #load("res://MapGen/Optional/PersonnelZone.tres")]
		$FacilityGenerator.rooms = rooms
	
	if get_node_or_null("PluginManager") != null:
		await get_tree().create_timer(0.375).timeout
		$LoadingScreen/LoadProgress.value = 55.0
		gamedata = gamedata.duplicate(true)
		$PluginManager._load_plugins()
	
	# Choose seed
	$FacilityGenerator.rng = rng
	if map_seed != -1:
		rng.seed = map_seed
		$FacilityGenerator.rng_seed = map_seed
	else:
		rng.randomize()
	$FacilityGenerator.generate_rooms()
	
	# Apply settings
	# Enable or disable glow
	$WorldEnvironment.environment.glow_enabled = Settings.setting_res.glow
	# Enable SSAO in OpenGL only in Godot 4.6
	if RenderingServer.get_current_rendering_method() == "forward_plus" || \
	 RenderingServer.get_current_rendering_method() == "gl_compatibility":
		$WorldEnvironment.environment.ssao_enabled = Settings.setting_res.ssao
	
	$WorldEnvironment.environment.tonemap_mode = Settings.setting_res.tonemapper
	if Settings.setting_res.tonemapper != Environment.TONE_MAPPER_LINEAR || \
	 Settings.setting_res.tonemapper != Environment.TONE_MAPPER_AGX:
		$WorldEnvironment.environment.tonemap_white = 2.0
	else:
		$WorldEnvironment.environment.tonemap_white = 1.0
	
	
	if Settings.setting_res.lighting != SettingsResource.Lighting.LIGHTMAP:
		if Settings.setting_res.lighting == SettingsResource.Lighting.NONE:
			$WorldEnvironment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			$WorldEnvironment.environment.ambient_light_color = Color(0.5, 0.5, 0.5)
		for node in get_tree().get_nodes_in_group("Lightmap"):
			if node is LightmapGI:
				node.queue_free()
	
	## Enable/disable reflection probes (cubemap)
	for node in get_tree().get_nodes_in_group("ReflectionProbe"):
		if node is ReflectionProbe:
			if !Settings.setting_res.reflection_probe: # || Settings.setting_res.ssr:
				node.hide()
			else:
				node.show()
				if Settings.setting_res.lighting == SettingsResource.Lighting.NONE:
					node.ambient_mode = ReflectionProbe.AMBIENT_COLOR
					node.ambient_color = Color(0.25, 0.25, 0.25, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Settings.setting_res.casual_mode_hunger && protagonist != null:
		# Hunger and thirst mechanic
		protagonist.health_manage(-delta * 0.25, 2, "GAME_OVER_THIRST")
		protagonist.health_manage(-delta * 0.1875, 3, "GAME_OVER_HUNGER")


func _on_facility_generator_generated() -> void:
	await get_tree().create_timer(0.375).timeout
	$LoadingScreen/LoadProgress.value = 75.0
	set_process(false)
	$UI/FPSCounter.set_process(false)
	spawn_offices("res://Assets/Rooms/ScientistsRooms/Default.tscn", "OfficeSpawn")
	
	spawn_player()
	
	spawn_puppets()
	set_process(true)
	$UI/FPSCounter.set_process(true)
	await get_tree().create_timer(0.375).timeout
	$LoadingScreen/LoadProgress.value = 87.5
	$AudioStreamPlayer.play()
	$FoundationTask.initialize()
	$UI._on_foundation_task_task_done()
	$SZ.set_time(8, 0)
	$StaticPlayer.set_physics_process(true)
	
	await get_tree().create_timer(0.375).timeout
	$LoadingScreen/LoadProgress.value = 100.0
	await get_tree().create_timer(5.0).timeout
	
	$LoadingScreen.call_deferred("hide")
	
## Spawns player-protagonist
func spawn_player():
	# Player and allies
	protagonist = load("res://PlayerScript/NPCBase.tscn").instantiate()
	protagonist.puppet_class = gamedata.player_class[0]
	protagonist.is_player = true
	
	var spawns = get_tree().get_nodes_in_group("PlayerSpawn")
	var selected_spawn: Marker3D = spawns[rng.randi_range(0, spawns.size() - 1)]
	protagonist.global_position = selected_spawn.global_position
	$NPCs.add_child(protagonist)
	$StaticPlayer.target_puppet_path = protagonist.get_path()
	#protagonist.keycards.append_array([-2584])

## Start-round spawn
func spawn_puppets():
	for puppet_res in gamedata.puppet_classes:
		if get_tree().get_nodes_in_group(puppet_res.spawn_point_group).size() == 0:
			continue
		var spawn_point_group: Array[Node] = get_tree().get_nodes_in_group(puppet_res.spawn_point_group)
		spawn_point_group.shuffle()
		#var used_spawns: Array[int] = []
		for i in range(puppet_res.initial_amount):
			if i > spawn_point_group.size() - 1:
				break
			#var random_number: int = rng.randi_range(0, spawn_point_group.size() - 1)
			#if used_spawns.has(random_number):
				#continue
			var npc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
			npc.puppet_class = puppet_res
			npc.position = spawn_point_group[i].global_position
			$NPCs.add_child(npc)
			#used_spawns.append(i)

## Personnel office spawner
func spawn_offices(default_office_path: String, spawn_group: String):
	var all_available_offices: Array[Node] = get_tree().get_nodes_in_group(spawn_group)
	all_available_offices.shuffle()
	for i in range(get_tree().get_node_count_in_group(spawn_group)):
		if i < gamedata.custom_scientists_offices.size():
			var office: Node3D = gamedata.custom_scientists_offices[i].instantiate()
			all_available_offices[i].add_child(office)
		else:
			var office: Node3D = load(default_office_path).instantiate()
			all_available_offices[i].add_child(office)

## Game end
func finish_game(good_end: bool, reason: String):
	if !game_ended:
		if get_node_or_null("SoundStreamPlayer") != null:
			var audio: AudioStreamPlayer = get_node("SoundStreamPlayer")
			audio.stream = load("res://Sounds/Generic/Win.ogg") if good_end else load("res://Sounds/Generic/Lose.ogg")
			audio.play()
		$UI/Condition/ConditionLabel.text = "GAME_WIN" if good_end else "GAME_OVER"
		$UI/Condition/ReasonLabel.text = reason
		$AnimationPlayer.play("condition_open")
		game_ended = true

## Cutscene animation
func cutscene_anim(reverse: bool = false):
	if reverse:
		$AnimationPlayer.play_backwards("cutscene")
	else:
		$AnimationPlayer.play("cutscene")

## Dialogue system from 7.0 and earlier.
func dialogue(text: String):
	advanced_dialogue([text])

## Dialogue system (used in 067, 983, 1223, 2028 and 2471)
func advanced_dialogue(random_text: Array, command_after: CommandResource = null):
	$UI/Dialogue.text = random_text[rng.randi_range(0, random_text.size() - 1)]
	for i in $UI/Dialogue.text.length():
		$UI/Dialogue.visible_characters = i
		await get_tree().physics_frame
	$UI/Dialogue.visible_characters = -1
	if command_after != null:
		protagonist._call_function(command_after.action_node_path, command_after.action_method_name, command_after.action_args)
	await get_tree().create_timer(2.0).timeout
	$UI/Dialogue.text = ""

## Shows image (6.0 version)
func showable(resource_path: String):
	show_image([resource_path])

## Shows random images (currently used for 067 and 1223)
## If specified, a command will be done after some seconds (if showed)
func show_image(images: Array, command_after: CommandResource = null, timer: float = 1.0):
	if (images != null && images.size() > 0):
		var resource_path: String = images[rng.randi_range(0, images.size() - 1)]
		if $UI/Showable.visible:
			$UI/Showable.hide()
			showable_res = ""
		elif resource_path != showable_res && (resource_path.begins_with("res://") || resource_path.begins_with("user://")):
			$UI/Showable.show()
			var res = load(resource_path)
			if res is Texture2D:
				$UI/Showable.texture = res
				showable_res = resource_path
				if command_after != null:
					if timer > 0.375:
						await get_tree().create_timer(timer).timeout
						$UI/Showable.hide()
						showable_res = ""
					protagonist._call_function(command_after.action_node_path, command_after.action_method_name, command_after.action_args)
				elif timer > 0.375:
					await get_tree().create_timer(timer).timeout
					$UI/Showable.hide()
					showable_res = ""
	else:
		$UI/Showable.hide()
		showable_res = ""

## Calls MTF.
func call_mtf():
	pass
	#if get_node("FoundationTask").has_task("task_ci") && mtf_cooldown <= 0.0:
		#spawn_wave_entity(0)
		#mtf_cooldown = 50.0


func _on_facility_generator_room_spawned() -> void:
	if OS.get_name() == "Web":
		await get_tree().create_timer(0.375).timeout

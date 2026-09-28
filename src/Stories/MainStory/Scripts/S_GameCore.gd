extends Node3D
class_name S_GameCore
## Game system.
## Made by Yni, licensed under MIT license.

signal round_started

@export var gamedata: GameData
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Presets for game ##
var map_seed: int = -1
## Current hours (is set by Surface Zone)
var hours: int = 8:
	set(val):
		hours = val
		if hours >= 20:
			$SZ.set_time(8, 0)
			$StoryModeNode.save_data["current_day"] += 1
## Current minutes (is set by Surface Zone)
var minutes: int = 0
## End presets for game ##

var mtf_cooldown: float = 35.0
## Protagonist tracker
var protagonist: MovableNpc
## Map seed public name
var map_seed_name: String = "":
	set(val):
		map_seed_name = val
		map_seed = hash(val)
## Check if the game was finished
var game_ended: bool = false


var showable_res: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.viewport_set_measure_render_time(get_tree().root.get_viewport_rid(), true)
	
	if $StoryModeNode.load_game():
		map_seed_name = $StoryModeNode.save_data["map_seed"]
		$Items.loading_startup = true
	
	gamedata = load("res://Stories/MainStory/Scripts/GameData/DefaultGame.tres")
	var rooms: Array[MapGenZone] = [load("res://Stories/MainStory/MapGen/Zones/MaintenanceZone.tres"), 
	   load("res://Stories/MainStory/MapGen/Zones/StorageZone.tres"), 
	   load("res://Stories/MainStory/MapGen/Zones/ResearchZone.tres"), 
	   load("res://Stories/MainStory/MapGen/Zones/PersonnelZone.tres")]
	$FacilityGenerator.rooms = rooms
	
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
	## Enable/disable reflection probes (cubemap)
	for node in get_tree().get_nodes_in_group("ReflectionProbe"):
		if node is ReflectionProbe:
			if !Settings.setting_res.reflection_probe: # || Settings.setting_res.ssr:
				node.hide()
			else:
				node.show()
	
	if Settings.setting_res.lighting != SettingsResource.Lighting.LIGHTMAP:
		if Settings.setting_res.lighting == SettingsResource.Lighting.NONE:
			$WorldEnvironment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			$WorldEnvironment.environment.ambient_light_color = Color(0.5, 0.5, 0.5)
		for node in get_tree().get_nodes_in_group("Lightmap"):
			if node is LightmapGI:
				node.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if protagonist != null:
		# Hunger and thirst mechanic
		protagonist.health_manage(-delta * 0.25, 2, "GAME_OVER_THIRST")
		protagonist.health_manage(-delta * 0.1875, 3, "GAME_OVER_HUNGER")
	if get_tree().root.get_node("Game/FoundationTask").get_amount_of_active_tasks() > 0:
		if $StoryModeNode.save_data["current_day"] == 5 && $StoryModeNode.save_data["quest_progress"] <= 7:
			finish_game(false, "S_GAMEOVER_TIMES_UP")
			$StoryModeNode.reset_save()
			set_process(false)
			return
		


func _on_facility_generator_generated() -> void:
	# Spawn surface zone
	#var sz: Node3D = load("res://Assets/Rooms/sublevels/External/subl_sz.tscn").instantiate()
	#sz.position.y = 256.0
	#add_child(sz, true)
	await get_tree().create_timer(0.375).timeout
	$LoadingScreen/LoadProgress.value = 75.0
	
	$SZ.set_time(8, 0)
	
	spawn_offices("res://Assets/Rooms/ScientistsRooms/Default.tscn", "OfficeSpawn")
	
	spawn_puppets()
	
	spawn_player()
	
	$Items.loading_startup = false
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
	$NPCs.add_child(protagonist)
	# Load location from save or start game
	if ($StoryModeNode.save_data["quest_progress"] < 0 || $StoryModeNode.save_data["scp"] < 0 || $StoryModeNode.save_data["current_day"] < 0) || \
	   ($StoryModeNode.save_data["quest_progress"] >= 9 && $StoryModeNode.save_data["scp"] > 0) || \
	   ($StoryModeNode.save_data["quest_progress"] < 9 && $StoryModeNode.save_data["scp_347_sh"]):
		Console.print_info("""If you found this message, you either modified save of the game,
or you encountered a bug,
that should be reported on https://github.com/Yni-Viar/scp-continued-path""", true)
		protagonist.global_position = $PD_basement/spawnpoint.global_position
	elif $StoryModeNode.save_data["location"].is_equal_approx(Vector3.ZERO) && $StoryModeNode.save_data["quest_progress"] == 0:
		var spawns = get_tree().get_nodes_in_group("StoryStart")
		if spawns.size() == 0:
			Console.print_error("""Encountered broken seed - scientist lounge was not spawned. Using workarounds...
Please, report bug to the developer on https://github.com/Yni-Viar/scp-continued-path .
Seed name: """ + map_seed_name, true)
			spawns = get_tree().get_nodes_in_group("PlayerSpawn")
		var selected_spawn: Marker3D = spawns[rng.randi_range(0, spawns.size() - 1)]
		protagonist.global_position = selected_spawn.global_position
		$SZ.set_time(8, 0)
		$UI/DialoguePanel/DialogueBox.start("dlg_start")
		$UI/DialoguePanel.show()
	else: #load save
		$SZ.set_time($StoryModeNode.save_data["hour"], 0) 
		$FoundationTask.add_task("s_task_" + str($StoryModeNode.save_data["quest_progress"]))
		$UI._on_foundation_task_task_done()
		protagonist.global_position = $StoryModeNode.save_data["location"]
		protagonist.money = $StoryModeNode.save_data["money"]
		for i in range($StoryModeNode.save_data["player_health"].size()):
			if i != 0 && $StoryModeNode.save_data["player_health"][i] < protagonist.health[i] / 4:
				protagonist.current_health[i] = protagonist.health[i] / 4
			else:
				protagonist.current_health[i] = $StoryModeNode.save_data["player_health"][i]
		if $StoryModeNode.save_data["quest_progress"] >= 6:
			protagonist.keycards.append(-2584)
		for item_id in $StoryModeNode.save_data["items"]:
			protagonist.get_node("UI/Inventory/Inventory").add_item(item_id)
		
		for removed_item_path in $StoryModeNode.save_data["removed_map_items"]:
			get_node(removed_item_path).queue_free()
		for added_item_path in $StoryModeNode.save_data["added_map_items"]:
			if $StoryModeNode.save_data["added_map_items"][added_item_path] is Array:
				if $StoryModeNode.save_data["added_map_items"][added_item_path].size() == 3:
					if gamedata.items.size() > $StoryModeNode.save_data["added_map_items"][added_item_path][0]:
						var pickable: Pickable = load(gamedata.items[$StoryModeNode.save_data["added_map_items"][added_item_path][0]].pickable_path).instantiate()
						$Items.add_child(pickable)
						if $StoryModeNode.save_data["added_map_items"][added_item_path][2] != null:
							if $StoryModeNode.save_data["added_map_items"][added_item_path][2] != {}:
								pickable.name = added_item_path.rsplit("/", true, 1)[1]
								pickable.item_id = -1
								pickable.item = gamedata.items[$StoryModeNode.save_data["added_map_items"][added_item_path][0]]
								pickable.item.custom_properties = $StoryModeNode.save_data["added_map_items"][added_item_path][2]
								pickable.global_position = $StoryModeNode.save_data["added_map_items"][added_item_path][1]
								continue
						pickable.name = added_item_path.rsplit("/", true, 1)[1]
						pickable.item_id = $StoryModeNode.save_data["added_map_items"][added_item_path][0]
						pickable.global_position = $StoryModeNode.save_data["added_map_items"][added_item_path][1]
	$StaticPlayer.target_puppet_path = protagonist.get_path()

func spawn_puppets():
	for puppet_res in gamedata.puppet_classes:
		var spawn_point_group = get_tree().get_nodes_in_group(puppet_res.spawn_point_group)
		spawn_point_group.shuffle()
		#var used_spawns: Array[int] = []
		if get_tree().get_nodes_in_group(puppet_res.spawn_point_group).size() == 0:
			continue
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

## Game over OR impassable game!
func finish_game(good_end: bool, reason: String):
	if !game_ended:
		if get_node_or_null("SoundStreamPlayer") != null:
			var audio: AudioStreamPlayer = get_node("SoundStreamPlayer")
			audio.stream = load("res://Sounds/Generic/Win.ogg") if good_end else load("res://Sounds/Generic/Lose.ogg")
			audio.play()
		$UI/Condition/ConditionLabel.text = "OOPS" if good_end else "GAME_OVER"
		$UI/Condition/ReasonLabel.text = "GAME_IMPASSABLE" if good_end else reason
		$AnimationPlayer.play("condition_open")
		game_ended = true

## True game win - lists credits, etc...
func complete_game() -> void:
	if !game_ended:
		$AnimationPlayer.play("game_end_open")
		if $StoryModeNode.save_data["scp"] > 0:
			$UI/CreditsContainer.launch_credits("S_SCP_FOUNDATION_WIN", load("res://UI/Optional/scp.png"))
		else:
			$UI/CreditsContainer.launch_credits("S_SERPENTS_HAND_WIN", load("res://UI/Optional/serpenthand.png"))
		$StoryModeNode.reset_save()
		game_ended = true
		Settings.setting_res.casual_mode_unlocked = true
		Settings.save_resource(Settings.setting_res)

## Sets credits music
func complete_game_audio_helper() -> void:
	$AudioStreamPlayer.stream = load("res://Sounds/Music/Original/Optional/SCP_MainTheme_v2.ogg")
	$AudioStreamPlayer.play()

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

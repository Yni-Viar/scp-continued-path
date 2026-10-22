extends InteractableStatic
## SCP-261 script
## Made by Yni, licensed under GPLv3.
class_name Scp261

@export var meals: Dictionary
@export_group("DON'T TOUCH - AUTOMATIC")
## Iterations for same SCP-261
@export var _iterations: int = 0
## Current category
@export var current_category: String
## Current food
@export var current_item: String
## To determine current iteration
@export var prev_category: String
## SCP-261 choice buttons
var base_buttons: Array[CommandResource] = []
## Eating buttons
var eat_buttons: Array[CommandResource] = []



func _ready() -> void:
	if FileAccess.file_exists("res://Scripts/Scps/Scp261Data/Scp261_" + OS.get_locale_language() + ".json"):
		var internal_file: FileAccess = FileAccess.open("res://Scripts/Scps/Scp261Data/Scp261_" + OS.get_locale_language() + ".json", FileAccess.READ)
		meals = JSON.parse_string(internal_file.get_as_text())
	else:
		var internal_file: FileAccess = FileAccess.open("res://Scripts/Scps/Scp261Data/Scp261_en.json", FileAccess.READ)
		meals = JSON.parse_string(internal_file.get_as_text())
	
	if OS.get_name() != "Web" || Settings.ALLOW_PLUGINS_IN_WEB:
		if !FileAccess.file_exists("user://Scp261.json"):
			var result_json: String = JSON.stringify(meals)
			var file: FileAccess = FileAccess.open("user://Scp261.json", FileAccess.WRITE)
			file.store_line(result_json)
			file.close()
		else:
			var file: FileAccess = FileAccess.open("user://Scp261.json", FileAccess.READ)
			var meals_text: String = file.get_as_text()
			if meals_text.begins_with("{"):
				var result_meals: Dictionary = JSON.parse_string(meals_text)
				if !result_meals.has("version") || result_meals["version"] is String:
					# New versioning system, if loading SCP-261 data from 9.x.x (SCP-261 1.x)
					# rewrite it.
					# Loads old SCP-261 1.x (used in 9.x.x versions of the game), or 2.0 (used in 10.0-10.5.0 versions of the game)
					file.close()
					var result_json: String = JSON.stringify(meals)
					file = FileAccess.open("user://Scp261.json", FileAccess.WRITE)
					file.store_line(result_json)
				elif result_meals["version"] < meals["version"]:
					# Upgrade system
					file.close()
					var result_json: String = JSON.stringify(meals)
					file = FileAccess.open("user://Scp261.json", FileAccess.WRITE)
					file.store_line(result_json)
				else:
					meals = result_meals
			file.close()
	base_buttons.resize(5)
	# For retrieving drink
	for i in range(5):
		var command_resource: CommandResource = CommandResource.new()
		command_resource.action_node_path = "SingleGroup:Scp261"
		command_resource.action_method_name = "scp_261"
		command_resource.action_args = [i+1]
		match i:
			0:
				command_resource.name = "100¥"
			1:
				command_resource.name = "300¥"
			2:
				command_resource.name = "500¥"
			3:
				command_resource.name = "700¥"
			4:
				command_resource.name = "1000¥"
		base_buttons[i] = command_resource
	# For eating products from SCP-261
	eat_buttons.resize(2)
	for i in range(2):
		var command_resource: CommandResource = CommandResource.new()
		match i:
			0:
				command_resource.action_node_path = "SingleGroup:Scp261"
				command_resource.action_method_name = "scp_261_item_eat"
				command_resource.name = "YES"
			1:
				command_resource.action_node_path = "SingleGroup:Scp261"
				command_resource.action_method_name = "scp_261_free"
				command_resource.name = "NO"
		eat_buttons[i] = command_resource

## Show dialogue
func interact(player: Node3D):
	super.interact(player)
	if player is MovableNpc:
		if player.is_player && player.money.has("YEN"):
			#Achievement
			if Settings.setting_res.scp_study_progress_all.has("SCP-261"):
				if !Settings.setting_res.scp_study_progress_all["SCP-261"]:
					Settings.setting_res.scp_study_progress_all["SCP-261"] = true
					Settings.save_resource(Settings.setting_res)
			Settings.dialogue_window("SCP261_CHOICE", "SCP-261", true, base_buttons)

## Main SCP-261 function
func scp_261(value: int):
	if prev_category.get_slice("_", 0) != current_category.get_slice("_", 0):
		_iterations = 0
	prev_category = current_category
	match value:
		1: #lowest
			if get_tree().root.get_node("Game").protagonist.money["YEN"] >= 100:
				get_tree().root.get_node("Game").protagonist.money["YEN"] -= 100
			else:
				return
			match _iterations:
				0:
					current_category = "lowest_1"
					current_item = meals["lowest_1"].keys().pick_random()
				1:
					current_category = "lowest_2"
					current_item = meals["lowest_2"].keys().pick_random()
				_:
					current_category = "lowest_3"
					current_item = meals["lowest_3"].keys().pick_random()
		2: #low
			if get_tree().root.get_node("Game").protagonist.money["YEN"] >= 300:
				get_tree().root.get_node("Game").protagonist.money["YEN"] -= 300
			else:
				return
			match _iterations / 2:
				0:
					current_category = "low_1"
					current_item = meals["low_1"].keys().pick_random()
				1:
					current_category = "low_2"
					current_item = meals["low_2"].keys().pick_random()
				_:
					current_category = "low_3"
					current_item = meals["low_3"].keys().pick_random()
		3: #mid
			if get_tree().root.get_node("Game").protagonist.money["YEN"] >= 500:
				get_tree().root.get_node("Game").protagonist.money["YEN"] -= 500
			else:
				return
			match _iterations / 2:
				0:
					current_category = "mid_1"
					current_item = meals["mid_1"].keys().pick_random()
				1:
					current_category = "mid_2"
					current_item = meals["mid_2"].keys().pick_random()
				_:
					current_category = "mid_3"
					current_item = meals["mid_3"].keys().pick_random()
		4: #high
			if get_tree().root.get_node("Game").protagonist.money["YEN"] >= 700:
				get_tree().root.get_node("Game").protagonist.money["YEN"] -= 700
			else:
				return
			match _iterations / 2:
				0:
					current_category = "high_1"
					current_item = meals["high_1"].keys().pick_random()
				1:
					current_category = "high_2"
					current_item = meals["high_2"].keys().pick_random()
				_:
					current_category = "high_3"
					current_item = meals["high_3"].keys().pick_random()
		5: #highest
			if get_tree().root.get_node("Game").protagonist.money["YEN"] >= 1000:
				get_tree().root.get_node("Game").protagonist.money["YEN"] -= 1000
			else:
				return
			match _iterations / 2:
				0:
					current_category = "highest_1"
					current_item = meals["highest_1"].keys().pick_random()
				1:
					current_category = "highest_2"
					current_item = meals["highest_2"].keys().pick_random()
				_:
					current_category = "highest_3"
					current_item = meals["highest_3"].keys().pick_random()
		_:
			printerr("Cannot choose food")
	_iterations += 1
	Settings.dialogue_window(tr("SCP261_EAT").format({SCP261_SUBJECT=current_item}), "SCP-261", true, eat_buttons)

func scp_261_item_eat():
	for item in meals[current_category][current_item]:
		match item.get_slice(":", 0):
			"health":
				var health_to_add: String = item.get_slice(":", 1)
				var health_type: String = item.get_slice(":", 2)
				if health_to_add.is_valid_float() && health_type.is_valid_int():
					get_tree().root.get_node("Game").protagonist._call_function("", "health_manage", [health_to_add.to_float(), health_type.to_int()])
			"message":
				get_tree().root.get_node("Game").protagonist._call_function("Game", "advanced_dialogue", [[item.get_slice(":", 1)]])
			"effect":
				get_tree().root.get_node("Game").protagonist.get_node("StatusEffects").apply_status_effect(item.get_slice(":", 1), 1.0, 15.0)

func scp_261_free():
	return

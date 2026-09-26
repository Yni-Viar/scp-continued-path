extends Control
## Main Menu
## Made by Yni, licensed under MIT license.

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	var total_amount: int = Settings.setting_res.scp_study_progress_all.size()
	var completed_amount: int = 0
	for progress in Settings.setting_res.scp_study_progress_all:
		if Settings.setting_res.scp_study_progress_all[progress]:
			completed_amount += 1
		else:
			var label: Label = Label.new()
			label.text = progress
			$AchievementContainer/Achievements/ScrollContainer/HBoxContainer.add_child(label)
	if OS.has_feature("Lite"):
		$LiteWarning.show()
	else:
		total_amount += Settings.setting_res.scp_study_progress_full.size()
		for progress in Settings.setting_res.scp_study_progress_full:
			if Settings.setting_res.scp_study_progress_full[progress]:
				completed_amount += 1
			else:
				var label: Label = Label.new()
				label.text = progress
				$AchievementContainer/Achievements/ScrollContainer/HBoxContainer.add_child(label)
		if randf() > 0.75 && Settings.setting_res.casual_mode_unlocked:
			$AudioStreamPlayer.stream = load("res://Sounds/Music/Original/Optional/SCP_MainTheme_v2.ogg")
	
	$AchievementContainer/Achievements/ProgressBar.max_value = total_amount
	$AchievementContainer/Achievements/ProgressBar.value = completed_amount
	
	#var index: int = 0
	#for node in $LorePanel/ScrollContainer/VBoxContainer.get_children():
		# Easy bit-field checking
		#node.visible = (Settings.setting_res.secrets >> index) % 2 == 1
		#index += 1
	
	
	if DirAccess.dir_exists_absolute("res://Stories/"):
		var available_stories: PackedStringArray = DirAccess.get_directories_at("res://Stories/")
		for story in available_stories:
			if ResourceLoader.exists("res://Stories/".path_join(story).path_join("Scenes/Game.tscn")):
				$StoryList.add_item(story, load("res://UI/MainMenu/Modes/storymode_select.png"))
	
	if Settings.setting_res.casual_mode_unlocked || OS.has_feature("Lite"):
		$HBoxContainer/Play.show()
		$ProjectInfo/HelpButton.show()
		if OS.has_feature("Lite"):
			$HBoxContainer/StoryMode.hide()
	
	if OS.get_name() == "Web":
		$HBoxContainer/Exit.queue_free()
	
	# Display game ratings in main menu in some countries, this will replace the game logo.
	if Settings.legal_req && !Settings.IS_STORE_BUILD:
		match Settings.region:
			"ru_RU":
				# New upcoming Russian law.
				$Logo.texture = load("res://UI/MainMenu/LawRegulation/RU.png")
	$ProjectInfo/GameVersion.text = "v" + ProjectSettings.get_setting("application/config/version")
	await get_tree().physics_frame
	
	if completed_amount == total_amount:
		$AchievementContainer/Achievements/Info2.text = "PROGRESS_SCP_STUDY_2"
		$AchievementContainer/Achievements/ScrollContainer.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_play_pressed() -> void:
	play()


func _on_credits_pressed() -> void:
	$CreditsContainer.visible = $ProjectInfo/Credits.button_pressed


func play():
	Settings.loader("res://Scenes/Game.tscn", {
		"map_seed": hash($HBoxContainer/Seed.text) if !$HBoxContainer/Seed.text.is_empty() else -1,
		"map_seed_name": $HBoxContainer/Seed.text if !$HBoxContainer/Seed.text.is_empty() else "random"
	})


func _on_help_button_pressed() -> void:
	$Tutorial.show()


func _on_story_mode_pressed() -> void:
	# Since there are no DLC (yet), load Main Story automatically
	#$StoryList.visible = !$StoryList.visible
	if $HBoxContainer/Seed.text == "yenjeai":
		$EasterEgg.show()
	else:
		var rnd_seed: String = random_seed()
		Settings.loader("res://Stories/MainStory/Scenes/Game.tscn", {
			"map_seed": hash($HBoxContainer/Seed.text) if !$HBoxContainer/Seed.text.is_empty() else hash(rnd_seed),
			"map_seed_name": $HBoxContainer/Seed.text if !$HBoxContainer/Seed.text.is_empty() else rnd_seed
		})


func _on_story_back_pressed() -> void:
	$EasterEgg.hide()


func _on_settings_button_pressed() -> void:
	$Settings.show()

func random_seed() -> String:
	var result_string: String = ""
	for i in range(16):
		result_string += char(randi_range(0x41, 0x7A))
	return result_string


func _on_story_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		if $HBoxContainer/Seed.text == "yenjeai":
			$EasterEgg.show()
		else:
			var rnd_seed: String = random_seed()
			Settings.loader("res://Stories/" + $StoryList.get_item_text(index) + "/Scenes/Game.tscn", {
				"map_seed": hash($HBoxContainer/Seed.text) if !$HBoxContainer/Seed.text.is_empty() else hash(rnd_seed),
				"map_seed_name": $HBoxContainer/Seed.text if !$HBoxContainer/Seed.text.is_empty() else rnd_seed
			})


func _on_contribute_pressed() -> void:
	OS.shell_open("https://github.com/Yni-Viar/scp-continued-procedures")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_support_pressed() -> void:
	OS.shell_open("https://boosty.to/yniviar")

extends Node3D
## Made by Yni, licensed under MIT License.
## Partly used Godot code snippet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() != "Web" || Settings.ALLOW_PLUGINS_IN_WEB:
		match get_parent().map_seed_name.to_lower():
			"hikkan":
				extract_easter_egg("res://PlayerScript/PlayerClassPrefab/EasterEgg/hikkan_m.zip")
			"hikkiko":
				extract_easter_egg("res://PlayerScript/PlayerClassPrefab/EasterEgg/hikkan_f.zip")

## SCP-2306 function
func scp_2306():
	if get_parent().protagonist.get_node("UI/Inventory/Inventory").has_item(23):
		for item: Item in get_parent().protagonist.get_node("UI/Inventory/Inventory").get_items(23):
			item.custom_properties["array_index"] = "images_happy"
		get_tree().root.get_node("Game/FoundationTask").do_task("task_5270_2306")
	get_parent().get_node("SoundStreamPlayer").stream = load("res://Sounds/Item/Scp2306/Original/Scp2306use.ogg")
	get_parent().get_node("SoundStreamPlayer").play()

func scp_983():
	if Time.get_datetime_dict_from_system()["month"] == 12 && Time.get_datetime_dict_from_system()["day"] == 29:
		get_parent().protagonist.health_manage(-127, 0, "GAME_OVER_SCP_983")
	else :
		get_parent().advanced_dialogue(["SCP983_NOT_BIRTHDAY"])

# Extract all files from a ZIP archive, preserving the directories within.
# This acts like the "Extract all" functionality from most archive managers.
func extract_easter_egg(archive_path: String):
	if !FileAccess.file_exists(archive_path):
		return
	
	var reader = ZIPReader.new()
	reader.open(archive_path)

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open("user://mods/puppets/custom/")

	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)

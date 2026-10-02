extends GameUI


func _physics_process(delta):
	for task_label in task_with_timer_labels:
		if task_with_timer_labels[task_label].time_left < 10.0:
			task_label.modulate = Color(1.0, 0.0, 0.0)
		elif task_with_timer_labels[task_label].time_left < 30.0:
			task_label.modulate = Color(1.0, 0.5, 0.0)
		elif task_with_timer_labels[task_label].time_left < 60.0:
			task_label.modulate = Color(1.0, 0.75, 0.0)
		else:
			task_label.modulate = Color(1.0, 1.0, 0.0)
	$CurrentTime.text = tr("DAY") + " " + str(get_tree().root.get_node("Game/StoryModeNode").save_data["current_day"] + 1) + " - " + str(get_parent().hours).lpad(2, "0") + ":" + str(get_parent().minutes).lpad(2, "0")


func _on_delete_save_pressed() -> void:
	get_parent().get_node("StoryModeNode").reset_save()	
	Settings.loader("res://Scenes/Menu.tscn", {})

# Sorry for duplicate code, but this is needed for story mode
func _on_foundation_task_event_done() -> void:
	task_with_timer_labels.clear()
	for prev_task in $Tasks.get_children():
		prev_task.queue_free()
	for task in get_parent().get_node("FoundationTask").all_tasks.keys():
		var label: Label = Label.new()
		label.add_theme_font_size_override("font_size", 20)
		label.text = get_parent().get_node("FoundationTask").all_tasks[task].game_task_resource.public_name
		$Tasks.add_child(label)
		if !get_parent().get_node("FoundationTask").all_tasks[task].timer_path.is_empty():
			var timer: Timer = get_node_or_null(get_parent().get_node("FoundationTask").all_tasks[task].timer_path)
			if timer != null:
				task_with_timer_labels[label] = timer
		$Tasks.add_child(HSeparator.new())
	if get_parent().get_node("FoundationTask").all_tasks.size() == 0:
		match get_parent().get_node("FoundationTask").special_event:
			0: # neutral
				get_parent().finish_game(true, "GAME_WIN_1")
			1: # temporary
				get_parent().finish_game(true, "GAME_WIN_1")
			2: # gameover - containment breach
				get_parent().finish_game(false, "GAME_OVER_CONTAINMENT_BREACH")
			3: # gameover - contact lost
				get_parent().finish_game(false, "GAME_OVER_UNKNOWN_ENTITIES")

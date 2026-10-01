extends GameUI


func _physics_process(delta):
	$CurrentTime.text = tr("DAY") + " " + str(get_tree().root.get_node("Game/StoryModeNode").save_data["current_day"] + 1) + " - " + str(get_parent().hours).lpad(2, "0") + ":" + str(get_parent().minutes).lpad(2, "0")


func _on_delete_save_pressed() -> void:
	get_parent().get_node("StoryModeNode").reset_save()	
	Settings.loader("res://Scenes/Menu.tscn", {})

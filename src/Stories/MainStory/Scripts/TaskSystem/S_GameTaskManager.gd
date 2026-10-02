extends GameTaskManager
## Game task manager
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name S_GameTaskManager

signal story_next_task
signal event_done

## Story complete task wrapper
func do_story_task() -> void:
	do_task("s_task_" + str(get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"]))
	get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] += 1
	add_task("s_task_" + str(get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"]))
	get_tree().root.get_node("Game/StoryModeNode").save_game()
	story_next_task.emit()

func trigger_event(event_type: SpecialEvent, res: GameTaskResource = null):
	super.trigger_event(event_type, res)
	event_done.emit()
	

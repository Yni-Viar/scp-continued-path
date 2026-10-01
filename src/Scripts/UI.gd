extends Control
## Made by Yni, licensed under MIT License.
## Uses third-party code. See code comment.
class_name GameUI

var exiting: bool = false
var current_elevator: ElevatorSystem = null
var input_amount: Dictionary[int, Vector2] = {}
var dragged: bool = false

var task_with_timer_labels: Dictionary[Label, Timer] = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#if !Settings.touchscreen:
		#$Back.hide()
		#$HBoxContainer/InventoryButton.hide()
		#$HBoxContainer/SwitchCameraButton.hide()

#
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	$CurrentTime.text = str(get_parent().hours).lpad(2, "0") + ":" + str(get_parent().minutes).lpad(2, "0")
	#$CurrentTime.modulate = Color(lerp(0.0, 1.0, get_parent().hours), lerp(1.0, 0.0, get_parent().hours), 0.0)
	for task_label in task_with_timer_labels:
		if task_with_timer_labels[task_label].time_left < 10.0:
			task_label.modulate = Color(1.0, 0.0, 0.0)
		elif task_with_timer_labels[task_label].time_left < 30.0:
			task_label.modulate = Color(1.0, 0.5, 0.0)
		elif task_with_timer_labels[task_label].time_left < 60.0:
			task_label.modulate = Color(1.0, 0.75, 0.0)
		else:
			task_label.modulate = Color(1.0, 1.0, 0.0)
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		_on_inventory_button_pressed()
	if event.is_action_pressed("photomode"):
		$HealthBar.visible = !$HealthBar.visible
		$ThirstBar.visible = !$ThirstBar.visible
		$HungerBar.visible = !$HungerBar.visible
		$HealthIcon.visible = !$HealthIcon.visible
		$ThirstIcon.visible = !$ThirstIcon.visible
		$HungerIcon.visible = !$HungerIcon.visible
		$Tasks.visible = !$Tasks.visible
		$HBoxContainer.visible = !$HBoxContainer.visible
		#if Settings.touchscreen:
		$Back.visible = !$Back.visible
		$CurrentTime.visible = !$CurrentTime.visible
		$FPSCounter.visible = !$FPSCounter.visible
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

#func _on_seed_text_changed(new_text):
	#if new_text != "":
		#get_parent().get_node("FacilityGenerator").rng_seed = hash(new_text)
	#else:
		#get_parent().get_node("FacilityGenerator").rng_seed = -1
#
#
#func _on_generate_pressed():
	#get_parent().get_node("FacilityGenerator").clear()
	#get_parent().get_node("FacilityGenerator").prepare_generation()

func end_screen_show():
	$Condition.show()

func _on_back_pressed() -> void:
	Settings.loader("res://Scenes/Menu.tscn", {})

# Check new task if task done, else finish game.
func _on_foundation_task_task_done() -> void:
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


func _on_inventory_button_pressed() -> void:
	$ElevatorMode.hide()
	$Scp914Panel.hide()

	get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/UI/Inventory").visible = !get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/UI/Inventory").visible


func _on_playing_area_gui_input(event: InputEvent) -> void:
	if Settings.touchscreen:
# BEGIN https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
# Copyright (c) 2014-present Godot Engine contributors.
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
# Licensed under MIT license
		var finger_count := input_amount.size()

		if finger_count == 0:
			# No fingers => Accept press.
			if event is InputEventScreenTouch:
				if event.pressed:
					# A finger started touching.

					input_amount[event.index] = event.position

		elif finger_count == 1:
			# One finger => For rotating around X and Y.
			# Accept one more press, unpress or drag.
			if event is InputEventScreenTouch:
				if input_amount.has(event.index):
					# Only touching finger released.
# END https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
					if dragged:
						dragged = false
					else:
						get_tree().root.get_node("Game/StaticPlayer").interact("Point")
# BEGIN https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
# Copyright (c) 2014-present Godot Engine contributors.
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
# Licensed under MIT license
					input_amount.clear()

			elif event is InputEventScreenDrag:
				if input_amount.has(event.index):
					# Touching finger dragged.
# END https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
					dragged = true
					get_tree().root.get_node("Game/StaticPlayer").rotate_player(event)
	elif Input.is_action_pressed("click"):
		get_tree().root.get_node("Game/StaticPlayer").interact("Point")
		Input.action_release("click")


func _on_call_mtf_button_pressed() -> void:
	get_parent().call_mtf()


func _on_scp_914_mode_drag_ended(value_changed: bool) -> void:
	if value_changed:
		get_tree().get_first_node_in_group("Scp914").mode = int($Scp914Panel/Scp914Mode.value)


func _on_refine_pressed() -> void:
	get_tree().get_first_node_in_group("Scp914").call("refine")
	$Scp914Panel.hide()


func _on_scp_914_button_pressed() -> void:
	get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/UI/Inventory").hide()
	$ElevatorMode.hide()
	$Scp914Panel.visible = !$Scp914Panel.visible


func _on_elevator_call_pressed() -> void:
	if current_elevator == null:
		return
	current_elevator.call_elevator(int($ElevatorMode/Floor.value))
	$ElevatorMode.hide()


func _on_elevator_button_pressed() -> void:
	get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/UI/Inventory").hide()
	$Scp914Panel.hide()
	$ElevatorMode.visible = !$ElevatorMode.visible


func _on_switch_camera_button_pressed() -> void:
	get_tree().root.get_node("Game/StaticPlayer").toggle_switcher()

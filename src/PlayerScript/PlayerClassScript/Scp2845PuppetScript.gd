extends SkinnablePuppetScript
## SCP-2845 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp2845PuppetScript

enum Scp2845State {DORMANT, ACTIVATED}

var deer_god_state: Scp2845State = Scp2845State.DORMANT


var counter: float = 72.0

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	if rng.randi_range(0, 32) < 30:
		get_parent().get_parent().queue_free()
		return
	Console.print_info("THE DEER GOD CAME TO THIS FACILITY!", true)
	plugin_api_function("start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	plugin_api_function("update")
	
	match state:
		States.IDLE:
			set_state("Idle")
		States.WALKING, States.RUNNING:
			set_state("Walk")
	
	if deer_god_state == Scp2845State.ACTIVATED && is_equal_approx($Timer.time_left - 18.0, counter):
		var players = get_tree().get_nodes_in_group("Players")
		var random_human: Node3D = players[rng.randi_range(0, players.size() - 1)] if rng.randi_range(0, 1) == 1 else get_tree().root.get_node("Game").protagonist
		get_parent().get_parent().global_position = random_human.global_position + random_human.global_transform.basis.z * 2
		get_parent().get_parent().follow_target = random_human.get_path()
		counter -= 18.0

func set_state(anim: String):
	if puppet_node.get_node("AnimationPlayer").current_animation != anim:
		puppet_node.get_node("AnimationPlayer").play(anim)

func activate():
	$Timer.start()
	deer_god_state = Scp2845State.ACTIVATED
	get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.NONE


func _on_timer_timeout() -> void:
	get_tree().root.get_node("Game").finish_game(true, "GAME_END_XK_SCP_2845")
	

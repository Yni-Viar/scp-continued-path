extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export_file("*.tres") var dlg_path: String = ""
@export var dlgs: Dictionary[String, bool] = {}

@export var dlg_index: int = -1
@export var face_right: bool = true

var root: SubViewport
var direction: float = 0.0

func _ready() -> void:
	root = find_parent("SubViewport")
	if root == null:
		queue_free()
	if !face_right:
		direction = -0.1
		await get_tree().physics_frame
		await get_tree().physics_frame
		direction = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction:
		velocity.x = direction * SPEED
		if direction < 0.0:
			$BigBadWolf.scale.x = -1.0
		else:
			$BigBadWolf.scale.x = 1.0
		$AnimationPlayer.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimationPlayer.play("idle")

	move_and_slide()


func _on_talk_trigger_body_entered(body: Node2D) -> void:
	if body is RRHPlayerScript:
		if dlg_index >= 0 && dlg_index < dlgs.size():
			root.get_node("Game/CanvasLayer/Control/DialogueBox").start(dlgs.keys()[dlg_index])
			root.get_node("Game/CanvasLayer/Control/DialogueBox").show()
			root.get_node("Game/Player").talking = true
			dlgs[dlgs.keys()[dlg_index]] = true

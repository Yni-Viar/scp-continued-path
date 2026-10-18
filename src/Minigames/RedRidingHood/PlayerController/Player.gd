extends CharacterBody2D
class_name RRHPlayerScript

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

## A workaround, where NPC cannot cross by NavigationLink, when something with navigation will move.
var prev_offset: PackedVector2Array = [Vector2.ONE, Vector2.ONE]

var talking: bool = false
var direction: float = 0.0
var cutscene: bool = false

#func _ready() -> void:
	#for i in range(prev_offset.size()):
		#prev_offset[i] = global_position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") && is_on_floor() && !talking:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if !cutscene && is_zero_approx(direction):
		direction = Input.get_axis("ui_left", "ui_right")
	if direction && !talking:
		velocity.x = direction * SPEED
		if direction < 0.0:
			$RedRidingHood.scale.x = -1.0
		else:
			$RedRidingHood.scale.x = 1.0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if stop_check(global_position) && is_on_floor():
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("idle")

	move_and_slide()
	
	prev_offset[1] = prev_offset[0]
	prev_offset[0] = global_position

## (Almost) precise check - is player actually moved
func stop_check(offset: Vector2) -> bool:
	var check: Vector2 = Vector2.ZERO
	for prev in prev_offset:
		check += prev
	check /= prev_offset.size()
	if offset.distance_squared_to(check) < 0.0001:
		return false
	else:
		return true


func _on_dialogue_box_dialogue_ended() -> void:
	talking = false

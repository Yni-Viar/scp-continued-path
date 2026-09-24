extends Node3D
## Made by Yni, licensed under СС0.

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_z(delta)
	if rotation_degrees.z > 360.0:
		rotation_degrees.z -= 360.0

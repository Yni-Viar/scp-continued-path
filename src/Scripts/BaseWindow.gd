extends Window
## Made by Yni, licensed under MIT License.
class_name BaseWindow

@export var deletable: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Compatibility with older behaviour
	if !close_requested.is_connected(_on_close_requested):
		close_requested.connect(_on_close_requested)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_close_requested() -> void:
	if deletable:
		queue_free()
	else:
		hide()

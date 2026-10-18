extends Node

#enum GameRoute {NONE, CANON, OUTSMART, HAPPYEND}
#
#var route: GameRoute = GameRoute.NONE



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Should be rewritten for embedded game
func change_scene(path: String) -> void:
	get_parent().get_node("Game").queue_free()
	var new_scene: Node = load(path).instantiate()
	await get_tree().create_timer(0.375).timeout
	get_parent().add_child(new_scene, true)
	if new_scene.get("game_settings") != null:
		new_scene.set("game_settings", get_path())

extends Node3D
## Made by Yni, licensed under MIT License.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Console.add_command("add_item", add_item, ["index"], 1)
	Console.add_command("spawn_npc", spawn_npc, ["index"], 1)
	Console.add_command("add_task", add_task, ["task_name"], 1)

## GDSh command
## Adds item to your inventory
func add_item(index: String):
	if index.is_valid_int():
		if int(index) < get_parent().gamedata.items.size() && int(index) >= 0:
			get_node(get_parent().get_node("StaticPlayer").target_puppet_path).call("_call_function", "UI/Inventory/Inventory", "add_item", [int(index)])

## GDSh command
## Spawns a NPC in front of you (make sure you run away, if it is hostile)
func spawn_npc(index: String):
	if index.is_valid_int():
		if int(index) < get_parent().gamedata.puppet_classes.size() && int(index) >= 0:
			var npc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
			npc.puppet_class = get_parent().gamedata.puppet_classes[int(index)]
			npc.position = get_parent().protagonist.global_position - get_parent().protagonist.global_transform.basis.z * 4
			get_parent().get_node("NPCs").add_child(npc)

## GDSh command
## Adds task manually, if it is possible to complete.
func add_task(task_name: String):
	if task_name is String:
		get_parent().get_node("FoundationTask").add_task(task_name)

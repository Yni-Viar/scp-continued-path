extends Resource
## Puppet resource
## Created by Yni, licensed under MIT License
class_name PuppetClass

## None - other player will do nothing
## Follow - other player will follow you
## Special action - Other player will do something if you interact (e.g. SCP-023 or SCP-1507)
enum InteractAction {NONE, FOLLOW, SPECIAL}

## None - player will not wander at all.
## Generic wander is MovableNpc wander implementation
## Limited wander - just moving from point to point.
enum WanderingSystem {NONE, GENERIC_WANDER, LIMITED_WANDER}

@export var puppet_class_name: String
@export var speed: float = 10.0
@export var prefab: PackedScene
## Group, where the game find spawnpoints
@export var spawn_point_group: String
@export var initial_amount: int
## What the second player should do when interacted?
@export var interacting_action: InteractAction = InteractAction.NONE
@export var footstep_sounds: Dictionary
## 0 is human, 1 is hostile SCP, 2 is vision SCP (like 650 and 173), 3 is must-not-look SCP (like 023), 4 is other classes, such as 2845
@export var fraction: int
@export var apply_height_bugfix: bool = true
@export var wandering_system: WanderingSystem = WanderingSystem.NONE
## Group of points for WanderingSystem.LIMITED_WANDER
@export var special_wandering_group: String = ""
## Will the puppet stay on this point, or it will wander.
## @deprecated Use `wandering_system` instead
@export var enable_wander: bool = true
## Health (0 is generic health, 1 is coldness (humans only),
## 2 is thirst (humans only), 3 is hunger (humans only)
@export var health: Array[float] = [100]
## Only for humans currently.
## 0 is none team, 1 is Foundation personnel, 2 is Class-D personnel,
## 3 is Chaos Insurgency, 2048 is friendly SCPs
@export var team: int = 0
## Enables avoidance
@export var enable_avoidance: bool = true
## Does the puppet spawn on start
@export var spawn_on_start: bool = true
@export_flags_3d_navigation var puppet_navigation_layers: int = 1
## Enables Inverse Kinematics (only for humans and SCP-347)
@export var enable_ik: bool = true
@export var ragdoll_prefab: PackedScene
## If disabled, player won't be stuck at elevator, but may be stuck on walls, if stopped there.
@export var disable_move_on_slide: bool = false
## Can NPCs ride the elevator?
@export var can_ride: bool = true
## Start items in inventory
@export var start_items: Array[int] = []
## Start money
@export var start_money: Dictionary[String, int]
## Enables AI (if it is available and enabled)
@export var enable_advanced_ai: bool = false
## Is character immortal or not (currently applies on SCP-080, SCP-181 and SCP-2845)
@export var immortal: bool = false
## Applied keycards
## Keycard examples:
## Protagonist has keycard with id -2021, which can open some doors
## id -2584 is required to open nuke in story mode
@export var keycards: Array[int] = []

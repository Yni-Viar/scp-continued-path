# How to create plugin for SCP: Continued Path?
⚠️ Currently, only puppets are supported!
## Plugin structure
Structure of a plugin:
```
~/mods/puppets/custom/:
|- 📁<plugin_name>
|  |- 📁scripts
|  |  |- <your scripts with .script extension>
|  |- 📄plugin.json
|  |- 📄<your_3d_model>.glb

```

[Where to find that folder?](./README.md)

## mila.gd
SCP: Continued Path uses [mila.gd](https://codeberg.org/ratrogue/mila.gd) (previously GOMPL or SLang.GD) as scripting language.

mila.gd syntax
```
a = 0 //variable

//if-elif-else

if a == 0 then
    print("null")
elif a == 5 then
    print("it can't be")
else
    print("can this be")
end

//while

x = 0
while x < 10 do
	x = x + 1
	if x == 3 then
		print("no three for thee")
		skip
	elif x == 6 then
		stop with x // the "with" part is optional
	end
	print(x)
end

//THERE IS NO FOR LOOP!

func() //function call
fun(a) //function call with parameters

//function can return builtin values, via defining <builtin_*> variables!

//local function
function funk()
    b = 2
    a = b
end

a = dictionary("name": "Klapauzius", "age": 10000, "weight": 123.4)
```



## plugin.json structure

```
{
	"name": `enter your plugin name (string)`, 
	"author": `enter your username (string)`,
	"year": `current year (int)`,
	"license": `license (usually CC-BY 4.0, CC-BY-SA 4.0/3.0)`,
    "api_version": `minimal supported API version, should be written as array with [major, minor, patch], such as [10, 2, 0]`
	"plugin_type": `"puppet"`,
	"gltf": {
		"gltf_file_prefix": `model prefix (generally, model's filename) (string)`,
        "gltf_file_suffix": `specific suffixes, made specially for SCP-131 (string)`,
        "gltf_path_to_find": `path to your gltf AND a plugin as whole (string)`
    },
    "puppet_resource": { `see more information at {project_root}/src/PlayerScript/PlayerClassResources/PuppetResource.gd`
        "speed": `speed of the puppet (float)`,
        "spawn_point_group": `Group, where the game find spawnpoints (string)`,
        "initial_amount": `Initial amount to spawn (int)`,
        "interacting_action": `(int)`,
            `0 - None - other player will do nothing`
            `1 - Follow - other player will follow you`
            `2 - Special action - Other player will do something if you interact`
        "fraction": `0 is human, 1 is hostile SCP, 2 is vision SCP (like 650 and 173), 3 is must-not-look SCP (like 023) (int)`,
        "team": `Only for humans currently.`
               `0 is none team, 1 is Foundation personnel, 2 is Class-D personnel,`
               `3 is Chaos Insurgency (int),`
        "wandering_system": `(int)`
           `0 - None - player will not wander at all.`
           `1 - Generic wander is MovableNpc wander implementation`
           `2 - Special wander is limited wander - just moving from point to point.`
        "special_wandering_group": `Group of points for WanderingSystem.LIMITED_WANDER (string)`,
        "health": `[
           `100.0, - necessary, but you can change it.`
           `50.0, - all of the others are`
           `50.0, optional, but if you use SkinnableHumanPuppetScript,`
           `50.0 - please use these values below.`
       `],`
       "enable_avoidance": `If you want to enable navigation avoidance (bool)`,
       "spawn_on_start": `Check if your puppet spawns on start (bool, has niche usage)`,
       "puppet_navigation_layers": `Navigation layers (int)`,
       "enable_ik": `For humans only - enable face inverse kinematics (bool)`,
       "disable_move_on_slide": `Disable physics check for puppet (bool)`,
       "can_ride": `can ride the elevator (bool)`,
       "start_items": `[] start items (int array)`,
       "start_money": `{} start money (dictionary with string as key and int as value)`,
       "enable_advanced_ai": `Enables picking advanced AI (bool, has niche usage)`,
       "immortal": `Godmode (bool)`,
       "keycards": `[] keycards available (int array, has niche usage)`
    },
    "animations": { `since API 10.4.0, not present in previous API levels`
		"enabled": `bool, check if you want animations included`,
		"animation_target_names": { `leave empty dict, if you do NOT want animations, or fill it with animation names`
			"idle": `Idle animation name (string)`,
			"walking": `Walking animation name (string)`,
            "running": `Running animation name (string)`,
            "special1": `Your own action animation name (string)`,
            "special2": `Your own action animation name (string)`,
            "special3": `Your own action animation name (string)`,
            "special4": `Your own action animation name (string)`
		}
	}
}
```

## Script naming
All files must have extension `.script`

### Common

`start.script` - does the same, as `_ready` function (from Godot). Supported in all SkinnablePuppetScripts.

`update.script` - does the same, as `_physics_process` function (from Godot). Supported in all SkinnablePuppetScripts.

`special_action.script` - do something on interaction. Supported in custom classes, SCP-023 (since v10.1.0), SCP-737 (since v10.1.0) and SCP-1507 (since v10.1.0)

### Built-in classes

`attack.script` - do something, when attacking. Only supported with SCP-1507 and SCP-939.

`blink_started.script` - do something, when blink started. Only supported with SCP-347.

`blink_ended.script` - do something, when blink ended. Only supported with SCP-173 and SCP-347.

`crunch.script` - do something on neck snap. Only supported with SCP-173.

`near_trigger_changed.script` - do something, if player enters your vision trigger. Only supported with SCP-939.

`teleport.script` - do something on teleport. Only supported with SCP-650.

### Custom classes
#### Scripts

`custom_action_1.script`, `custom_action_2.script`, `custom_action_3.script`, `custom_action_4.script` - do something in these 4 functions.

`player_entered_vision_area.script` - do something, if puppet goes into vision trigger.

`player_exited_vision_area.script` - do something, if puppet is leaving vision trigger.


`player_entered_trigger.script` - if protagonist entered user-defined trigger

`puppet_entered_trigger.script` - if NPC entered entered user-defined trigger

`player_exited_trigger.script` - if protagonist exited user-defined trigger

`puppet_exited_trigger.script` - if NPC exited user-defined trigger

## Script Functions
### Special functions
`spawn_trigger(shape, size, collider_rotation_x, collider_rotation_y, collider_rotation_z, position_from_center_x, position_from_center_y, position_from_center_z, height)`- Spawns trigger (if it does not already exist), where
`shape` is enum (use as int in GOMPL):
```
0 is Sphere shape
1 is Box shape
2 is Capsule shape
3 is Cylinder shape
```
`size` is primary size or radius (float).
`collider_rotation_x`, `collider_rotation_y`, `collider_rotation_z` is rotation of collider (floats, defaults to 0)
`position_from_center_x`, `position_from_center_y`, `position_from_center_z` is position of an Area3D from center (floats, defaults to 0)
`height` - for usage with Capsule and Cylinder shapes, defaults to 1.0.

### Getters-setters

> ⚠️ Due to mila.gd limitation, getters are implemented as global variables, started with `builtin_`,
> such as `builtin_follow`, `builtin_player_global_pos`, etc...

> ℹ️ Since API v10.3.0, Plugin API cannot call native functions for security reasons.

`get_distance_to_player()` Gets distance to player (`builtin_distance_to_player`)

`get_follow()` - Gets follow path, which this custom puppet follows (`builtin_follow`)

`set_follow(path: String)` - Sets follow path, which this custom puppet will follow. (For advanced scenarios, use `go_to_target(target_path)`)

`get_front_facing()` - Gets global_transform.basis.z of self (`builtin_front_facing`)

> In API v10.0.0 3 floats were used for front facing, located as builtin_front_facing_x/y/z

`get_global_pos()` - Gets position of self as 3 floats (`builtin_global_pos`)

> In API v10.0.0 3 floats were used for position, located as builtin_global_pos_x/y/z

`set_global_pos(x: float, y: float, z: float)` - Sets position of self

`set_global_pos(pos: Vector3)` - Sets position of self

`get_immortal()` - Gets godmode status (`builtin_immortal`)

`set_immortal(value: bool)` - Sets godmode status

`get_movement_freeze()` - Gets movement freeze of self (`builtin_movement_freeze`)

`set_movement_freeze(value: bool)` - Sets movement freeze on self

`get_player_front_facing()` - Gets global_transform.basis.z of self (`builtin_player_front_facing`)

> In API v10.0.0 3 floats were used for front facing, located as builtin_player_front_facing_x/y/z

`get_player_global_position()` - Gets protagonists' global position as vector3 (`builtin_player_global_pos`)

> In API v10.0.0 3 floats were used for position, located as builtin_player_global_pos_x/y/z

`set_global_posv(pos: Vector3)` - Sets global position as Vector3.

> Available only in API v10.3.0 and higher

`get_global_rot(in_degrees: bool)` - Gets rotation of self. Use `get_global_rot(true)` if you want in degrees, or `get_global_rot(true)` - for radians. (`builtin_global_rot`)

> Available only in API v10.3.0 and higher

`set_global_rot(in_degrees: bool, x: float, y: float, z: float)` - Sets rotation (`true` for degrees, `false` for radians) of self by `x`, `y`, and `z`.

> Available only in API v10.3.0 and higher

`set_global_rotv(in_degrees: bool, rot: Vector3)` - Sets rotation (`true` for degrees, `false` for radians) of self by `rot` as Vector3.

> Available only in API v10.3.0 and higher

`player_get_path()` - Gets protagonist's node path (`builtin_player_path`)

> Available only in API v10.4.0 and higher

`get_pth()` - Gets your own node path (`builtin_path`)

> Available only in API v10.4.0 and higher

### Functions

`add_item(item_id: int)` - Adds item to self

`player_add_item(item_id: int)` - Adds item to player

`interaction_sound(sound_path: String)` - Plays custom sound, that is placed in `mod_path`/sounds/

`health_manage(health_to_add: float, health_type: int = 0, deplete_reason: String = "")` - Adds or depletes health for self

`player_health_manage(health_to_add: float, health_type: int = 0, deplete_reason: String = "")` - Adds or depletes health for player

`remove_item(item_id: int, drop: bool = false)` - Remove item from self

`player_remove_item(item_id: int, drop: bool = false)` - Remove item from player

`player_get_all_items()` - Gets all items in inventory as IDs
> Available only in API v10.1.0 and higher

`go_to_target(target_path: String)` - Sets follow path, which this custom puppet will follow. This puppet will use Surface Zone elevators to reach you.
> Available only in API v10.1.0 and higher

`player_set_status_effect(effect: String, strength: float, duration: float)` - Set specific status effect for puppet
> Available only in API v10.1.0 and higher

`despawn()` - a.k.a queue_free() in Godot - despawns character
> Available only in API v10.3.0 and higher
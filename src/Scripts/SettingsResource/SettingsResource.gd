extends Resource
class_name SettingsResource
## Made by Yni, licensed under MIT License.

## KeyBoard, MouseButton, JoyPad
enum InputMethod {KB, MB, JP}

enum Lighting {NONE, LIGHTMAP, REALTIME}

enum Renderer {OPENGL, RD_MOBILE, RD_FORWARD_PLUS}

## Music
@export var music: float = 1.0
## Sound
@export var sound: float = 1.0
## Mouse sensitivity
@export var mouse_sensitivity: float = 0.05
## Glow setting
@export var glow: bool = true
## Reflection probe setting
@export var reflection_probe: bool = true
## Music volume
@export var music_volume: float = 1.0
## Keybinds
@export var keybinds: Dictionary[String, Array] = {
	"click": [InputMethod.MB, MOUSE_BUTTON_LEFT],
	"camera_rotate_left": [InputMethod.KB, KEY_A],
	"camera_rotate_right": [InputMethod.KB, KEY_D],
	"toggle_mode": [InputMethod.KB, KEY_SPACE],
	"inventory": [InputMethod.KB, KEY_TAB],
	"photomode": [InputMethod.KB, KEY_P],
	"move_forward": [InputMethod.KB, KEY_W],
	"move_backward": [InputMethod.KB, KEY_S],
}
## SSAO
@export var ssao: bool = false
## Tonemapper
@export var tonemapper: Environment.ToneMapper = Environment.TONE_MAPPER_LINEAR
## AI enabled
@export var ai_enabled: bool = false
## Lighting
@export var lighting: Lighting = Lighting.LIGHTMAP
## Rendering
@export var renderer: Renderer = Renderer.OPENGL
## SCP study progress
@export var scp_study_progress_all: Dictionary[String, bool] = {
	"SCP-005": false,
	"SCP-018": false,
	"SCP-023": false,
	"SCP-067": false,
	"SCP-079": false,
	"SCP-131": false,
	"SCP-162": false,
	"SCP-173": false,
	"SCP-249": false,
	"SCP-261": false,
	"SCP-347": false,
	"SCP-522": false,
	"SCP-650": false,
	"SCP-686": false,
	"SCP-737": false,
	"SCP-812": false,
	"SCP-939": false,
	"SCP-1507": false,
	"SCP-2028": false,
	"SCP-2306": false,
	"SCP-5270": false
}

@export var scp_study_progress_full: Dictionary[String, bool] = {
	"SCP-080": false,
	"SCP-178": false,
	"SCP-791": false,
	"SCP-914": false
}
## Casual mode unlocked
@export var casual_mode_unlocked: bool = false
## Beta mode enabled
@export var beta_mode: bool = false
## Enables hunger mechanics in casual mode
@export var casual_mode_hunger: bool = true
## Enables advanced sky
@export var enable_advanced_sky: bool = false

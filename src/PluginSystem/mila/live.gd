extends Sprite2D

@export_multiline var code := "counter = 0\nspeed = array(-2, 5, 20).pick_random()\nwhile true do\n\tdt = get_process_delta_time()\n\trotate(speed * dt)\n\t// move_local_x(5)\n\tprint(counter += 1)\n\tinterrupt\nend"
@export var code_editor: TextEdit
@export var code_compile: Button
@export var code_error: Label
@export var maxsteps_edit: TextEdit
@export var looping_toggle: CheckButton
@export var info_label: Label

## We reuse mila.gd's state
var state := {}
var maxsteps := 2000
var is_looping := true
var executing := true

@onready var orig_transform := self.transform
@onready var mila := Mila.new(self)

## The `_mila_prefix` String variable is used by mila.gd to determine which methods can be called.
## The default is "_mila_", and usually it's not recommended to set it to an empty string, as this
## gives access to potentially dangerous methods like queue_free().
@warning_ignore("unused_private_class_variable") var _mila_prefix := ""

###

func _ready() -> void:
	mila.register_func("print", func(a): a = a if a != null else "undefined"; code_error.text += str(a, "\n"); return str(a), [ Mila.T_ANY ])
	mila.register_func("rnd", randf) # func(): return randf())
	mila.register_func("mouse_pos", func() -> Vector2: return get_viewport().get_mouse_position())
	mila.register_func("v2", func(x: float, y: float) -> Vector2: return Vector2(x, y), [ Mila.T_NUMBER, Mila.T_NUMBER ])
	
	code_editor.text = code
	code_compile.button_down.connect(on_code_compile)
	maxsteps_edit.text_changed.connect(on_maxsteps_edit)
	maxsteps_edit.text = str(maxsteps)
	looping_toggle.toggled.connect(on_looping_toggled)
	on_code_compile()

func _process(_delta: float) -> void:
	if executing:
		code_error.text = ""
		if not mila.err:
			var tokens := mila.tokenize_code(code)
			var ast: Mila.Expr = null
			var instructions: Array[Array]
			
			# the code is compiled every frame, this is wasteful - try to reuse the tokens, ast and instructions
			# variables whenever possible
			if tokens:
				ast = mila.parse_tokens(tokens)
				if ast:
					instructions = mila.compile(ast)
					if instructions:
						mila.run(instructions, null, state, maxsteps)
			# to tokenize, compile and run in one call, use mila.eval(code, null, state, maxsteps)
			
			info_label.text = ""
			if mila.err: code_error.text = "ERROR! " + mila.err; executing = false
			
			info_label.text = str("Lines: ", code_editor.text.strip_edges(false).count("\n") + 1, "\n",
				"Chars: ", code_editor.text.strip_edges().length(), "\n",
				"Tokens: ", tokens.size(), "\n",
				"Expressions: ", count_expressions(ast), "\n",
				"Instructions: ", instructions.size(), "\n",
				"Global vars: ", mila.cur_state.get(&"env", {}).size())
			#mila.debug_printing = false
	if not is_looping:
		executing = false

func count_expressions(expr) -> int:
	if not expr or expr is not Mila.Expr: return 0
	var c := 1
	for d: Dictionary in expr.get_property_list():
		var e = expr.get(d.name)
		if e is Array:
			for ee in e:
				if ee is Mila.Expr: c += count_expressions(ee)
		elif e is Mila.Expr: c += count_expressions(e)
	return c

###

func on_code_compile() -> void:
	code_error.text = ""
	#mila.debug_printing = true
	state.clear()
	code = code_editor.text
	mila.err = ""
	transform = orig_transform
	executing = true

func on_maxsteps_edit() -> void:
	maxsteps = clampi(int(maxsteps_edit.text), 1, 5000)

func on_looping_toggled(toggled_on: bool) -> void:
	is_looping = toggled_on
	if toggled_on: executing = true

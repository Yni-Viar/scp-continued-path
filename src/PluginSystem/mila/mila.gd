class_name Mila
extends RefCounted

## A simple interpreted scripting language for Godot
## Codeberg repo: https://codeberg.org/ratrogue/Mila.gd
## Based on https://jayconrod.com/posts/37/a-simple-interpreter-from-scratch-in-python--part-1-
## and https://jayconrod.com/posts/65/how-to-build-a-parser-by-hand
## and https://craftinginterpreters.com/parsing-expressions.html

const _IGNORE := "IGN"
const _RESERVED := "RSV"
const _INT := "INT"
const _FLOAT := "FLT"
const _STRING := "STR"
const _UNDEFINED := "NIL"
const _BOOL := "BOOL"
const _ID := "ID"
const _ID_FUNC := "IDFN"
const _OBJECT := "OBJ"
const _TOKEN_EXPRESSIONS: Array[String] = [
	r"[ \n\t]+", _IGNORE, # whitespace
	r"#[^\n]*", _IGNORE, r"\/\/[^\n]*", _IGNORE, # comment
	r",", _RESERVED, r":", _RESERVED, # separator
	r"\.\.\.", _RESERVED, # specifier
	r"\.", _RESERVED, r"\[", _RESERVED, r"\]", _RESERVED, # access
	r"\+=", _RESERVED, r"-=", _RESERVED, r"\*=", _RESERVED, r"/=>", _RESERVED, r"\%=>", _RESERVED,
	r"\+", _RESERVED, r"-", _RESERVED, r"\*", _RESERVED, r"/", _RESERVED, r"\%", _RESERVED,
	r"<=", _RESERVED, r"<", _RESERVED, r">=", _RESERVED, r">", _RESERVED, r"==", _RESERVED, r"!=", _RESERVED, 
	r"=", _RESERVED, r"\(", _RESERVED, r"\)", _RESERVED,
	r"[0-9]+\.[0-9]*", _FLOAT, r"[0-9]+", _INT, r"\"(.*?(?<!\\))\"", _STRING, r"[A-Za-z_][A-Za-z0-9_]*", _ID
]
const _TOKEN_AND: Array[String] = [ "and" ]
const _TOKEN_OR: Array[String] = [ "or" ]
const _TOKEN_EQUALITY: Array[String] = [ "==", "!=" ]
const _TOKEN_COMPARISON: Array[String] = [ "<=", "<", ">=", ">" ]
const _TOKEN_TERM: Array[String] = [ "-", "+" ]
const _TOKEN_FACTOR: Array[String] = [ "/", "*", "%" ]
const _TOKEN_UNARY: Array[String] = [ "not", "-" ]
const _TOKEN_ASSIGNMENT: Array[String] = [ "=", "+=", "-=", "*=", "/=", "%=" ]
const _TOKEN_PAIR: String = ":"
const _TOKEN_ACCESS: String = "."
const _TOKEN_BINARY_OPERATOR: Array[String] = [ "+", "-", "*", "/", "%" ]
const _TOKEN_BINARY_OPERATOR_ALLOW_UNDEFINED: Array[String] = [ "+" ]
const _TOKEN_FLOW_CONTROL: Array[String] = [ "stop", "skip", "exit", "interrupt" ]
const _TOKEN_KEYWORDS: Array[String] = [ "and", "or", "not", "if", "then", "else", "elif", "while", "of",
	"do", "end", "stop", "skip", "exit", "interrupt", "with", "function" ]
const _TOKEN_UNDEFINED: Array[String] = [ "undefined" ]
const _TOKEN_BOOLS: Array[String] = [ "true", "false" ]
const _TOKEN_CONTAINERS: Array[String] = [ "array", "dictionary" ]
const _TOKEN_VECTORS: Array[String] = [ "vector2", "vector3", "vector4", "vector2i", "vector3i", "vector4i" ]

enum Instruction { UNDEFINED, BINARY_LOGIC, BINARY_LOGIC_END, BINARY, UNARY, ASSIGN, ASSIGN_IDX, PAIR, LITERAL,
	POP, IDENTIFIER, CHECK, JUMP, INTERRUPT, CALL_METHOD, CALL_INTERNAL, RETURN, CALL_EXTERNAL, CREATE_ARRAY, CREATE_DICTIONARY,
	CREATE_STRUCTURE, ACCESS_IDX, ITERATE, ITERATE_CONTINUE, ITERATE_CLEAR }

const _TYPES_STRING: Array[int] = [ TYPE_STRING, TYPE_STRING_NAME ]
const _TYPES_NUMBER: Array[int] = [ TYPE_INT, TYPE_FLOAT ]
const _TYPES_ITERABLE: Array[int] = [ TYPE_INT, TYPE_FLOAT, TYPE_ARRAY, TYPE_DICTIONARY, TYPE_STRING, TYPE_STRING_NAME ]
const _TYPES_CONTAINER: Array[int] = [ TYPE_ARRAY, TYPE_DICTIONARY ]
const _TYPES_VECTORS: Dictionary = { TYPE_VECTOR2: [ "x", "y" ], TYPE_VECTOR3: [ "x", "y", "z" ], TYPE_VECTOR4: [ "x", "y", "z", "w" ], TYPE_VECTOR2I: [ "x", "y" ], TYPE_VECTOR3I: [ "x", "y", "z" ], TYPE_VECTOR4I: [ "x", "y", "z", "w" ] }
const _TYPES_INDEX_ACCESS: Array[int] = [ TYPE_STRING, TYPE_STRING_NAME, TYPE_ARRAY, TYPE_DICTIONARY ]
const _TYPES_INDEX_ACCESS_LEFT_SIDE: Array[int] = [ TYPE_ARRAY, TYPE_DICTIONARY ]

var debug_printing := false
var err: String
var target: Object
var is_running := false
var cur_state: Dictionary
var _cur_env: Dictionary

const T_ANY := &"any"
const T_NUMBER := &"number"
const T_STRING := &"string"
const T_UNDEFINED := &"undefined"

var _registered_in_funcs: Dictionary
var _registered_ex_funcs: Dictionary

###

func _init(target_object: Object = null) -> void:
	self.target = target_object

###

## param_types is an array filled with types (T_ANY, TYPE_INT, Mila.T_NUMBER, etc.)
## optional_params is the amount of optional parameters of the function
func register_func(func_name: String, callable: Callable, param_types: Array = [], optional_params := 0, is_variadic := false) -> void:
	if not func_name or not callable: printerr("Invalid function registration"); return
	if func_name in _registered_ex_funcs: printerr("Function name already registered"); return
	_registered_ex_funcs[func_name] = [ callable, param_types, optional_params, is_variadic ]
	
func unregister_func(func_name: String) -> void:
	_registered_ex_funcs.erase(func_name)

## env is a Dictionary that contains all the variables assigned in the code
func eval(code: String, env = null, state = null, max_steps := -1, clear_internal_funcs := true) -> Variant:
	var tokens := tokenize_code(code)
	if not tokens: return null # some error happened
	var ast := parse_tokens(tokens, clear_internal_funcs)
	if not ast: return null # some error happened
	var instructions := compile(ast)
	if not instructions: return null # some error happened
	return run(instructions, env, state, max_steps)

###

## Step 1 - returns the tokens of the code
func tokenize_code(code: String) -> Array[Array]:
	err = ""
	var tokens := _lex(code)
	if err: printerr(err); return []
	if debug_printing and tokens: print("*** TOKENS (", tokens.size(), "): ", tokens)
	return tokens

## Step 2 - returns the AST (abstract syntax tree) of the tokens
func parse_tokens(tokens: Array[Array], clear_internal_funcs := true) -> Expr:
	err = ""
	if clear_internal_funcs: _registered_in_funcs.clear()
	var parser := Parser.new(self, tokens)
	if err: printerr(err); return null
	var ast := parser.parse()
	if err: printerr(err); return null
	if debug_printing: print("*** AST: ", ast)
	return ast
	
## Step 3 - compile the AST to an arry of instructions
func compile(ast: Expr) -> Array[Array]:
	err = ""
	var it: Array[Array]
	var scope := Scope.new(0)
	ast.compile(self, it, [ scope ])
	if _registered_in_funcs:
		var jump := [ it[-1][0] if it else 0, Instruction.JUMP ]
		scope.stops.append(jump) # final end instruction
		it.append(jump)
		for f: Expr.Function in _registered_in_funcs.values(): f.compile_deferred(self, it)
	scope.init_stops(it.size())
	if err: printerr(err); return []
	if debug_printing and it: print("*** INSTRUCTIONS (", it.size(), "): ", it.map(func(a: Array) -> Array: var b: Array = a.duplicate(); b[1] = Instruction.keys()[b[1]]; return b))
	return it

## Step 4 - iterate over the array of instructions, using it as a lower level language
## env is a Dictionary that contains all the variables assigned in the code
## If you don't provide env, the one from state will be used (if it exists), or a temporary one will be created 
## If you provide a state Dictionary, it can be re-used to continue the execution after it was interrupted
## (but you can also use the cur_state member for that)
func run(it: Array[Array], env = null, state = null, max_steps := -1) -> Variant:
	if is_running:
		printerr("Interpreter is already running!")
		breakpoint
		return null
	
	err = ""
	if env == null: env = {} if state is not Dictionary else state.get(&"env", {})
	elif env is not Dictionary: _set_err("Environment must be a Dictionary"); env = {}
	_cur_env = env
	
	if state is not Dictionary: state = {}
	cur_state = state
	
	var step: int = 0
	var stack: Array = state.get(&"stack", [])
	var fncalls: Array = state.get_or_add(&"fncalls", [])
	var pos: int = state.get(&"pos", 0)
	
	is_running = true
	while not err and pos < it.size():
		if &"interrupted" in state:
			break
		var line: int = it[pos][0]
		#print_rich("run St:", step, " P:", pos, " Ln:", it[pos][0], " It:", Instruction.keys()[it[pos][1]], " ", it[pos].slice(2), " - [color=green]stack:", stack, "[/color] env:", env, " fnc:", fncalls)
		match it[pos][1]:
			Instruction.UNDEFINED:
				stack.push_back(Undefined.new(line))
			Instruction.BINARY_LOGIC:
				var l = stack.pop_back()
				if it[pos][2] == "and":
					if not l or l is Undefined: stack.push_back(false); pos = it[pos][3] - 1
				elif it[pos][2] == "or":
					if l and l is not Undefined: stack.push_back(true); pos = it[pos][3] - 1
			Instruction.BINARY_LOGIC_END:
				var r = stack.pop_back()
				stack.push_back(r and r is not Undefined)
			Instruction.BINARY:
				var r = stack.pop_back()
				var l = stack.pop_back()
				var rt := typeof(r)
				var lt := typeof(l)
				var incomp := false
				if it[pos][2] == "==":
					if lt in _TYPES_STRING and rt in _TYPES_STRING: stack.push_back(l == r)
					elif lt in _TYPES_NUMBER and rt in _TYPES_NUMBER: stack.push_back(l == r)
					elif l is Undefined and r is Undefined: stack.push_back(true)
					else: stack.push_back(typeof(l) == typeof(r) and l == r)
				elif it[pos][2] == "!=":
					if lt in _TYPES_STRING and rt in _TYPES_STRING: stack.push_back(l != r)
					elif lt in _TYPES_NUMBER and rt in _TYPES_NUMBER: stack.push_back(l != r)
					elif l is Undefined and r is Undefined: stack.push_back(false)
					else: stack.push_back(typeof(l) != typeof(r) or l != r)
				elif (l is Undefined or r is Undefined) and it[pos][2] not in _TOKEN_BINARY_OPERATOR_ALLOW_UNDEFINED:
					stack.push_back(Undefined.new(line))
				elif it[pos][2] in _TOKEN_BINARY_OPERATOR:
					match it[pos][2]:
						"+":
							if lt in _TYPES_NUMBER and rt in _TYPES_NUMBER: stack.push_back(l + r)
							elif lt in _TYPES_STRING or rt in _TYPES_STRING: stack.push_back(str(l, r))
							elif lt in _TYPES_VECTORS and lt == rt: stack.push_back(l + r)
							elif l is Undefined or r is Undefined: stack.push_back(Undefined.new(line))
							else: incomp = true
						"-":
							if lt in _TYPES_NUMBER and rt in _TYPES_NUMBER: stack.push_back(l - r)
							elif lt in _TYPES_STRING: stack.push_back(l.replace(str(r), ""))
							elif lt in _TYPES_VECTORS and lt == rt: stack.push_back(l - r)
							else: incomp = true
						"*":
							if lt in _TYPES_NUMBER and rt in _TYPES_NUMBER: stack.push_back(l * r)
							elif lt in _TYPES_STRING and rt in _TYPES_NUMBER: stack.push_back(l.repeat(r))
							elif lt in _TYPES_NUMBER and rt in _TYPES_STRING: stack.push_back(r.repeat(l))
							elif lt in _TYPES_VECTORS and (rt == lt or rt in _TYPES_NUMBER): stack.push_back(l * r)
							elif lt in _TYPES_NUMBER and rt in _TYPES_VECTORS: stack.push_back(l * r)
							else: incomp = true
						"/":
							if (lt in _TYPES_NUMBER or lt in _TYPES_VECTORS) and rt in _TYPES_NUMBER:
								if r == 0: _set_err_runtime(stack, it[pos], "Division by zero")
								else: stack.push_back(l / r)
							elif lt in _TYPES_VECTORS and lt == rt:
								for c: String in _TYPES_VECTORS[rt]: if r[c] == 0: _set_err_runtime(stack, it[pos], "Division by zero"); break
								if not err: stack.push_back(l / r)
							else: incomp = true
						"%":
							if lt in _TYPES_NUMBER and rt in _TYPES_NUMBER:
								if r == 0: _set_err_runtime(stack, it[pos], "Division by zero")
								else: stack.push_back(l % r)
							elif lt in _TYPES_STRING and rt in _TYPES_CONTAINER: stack.push_back(l.format(r))
							else: incomp = true
				else:
					if (lt in _TYPES_NUMBER and rt in _TYPES_NUMBER) or (lt in _TYPES_STRING and rt in _TYPES_STRING):
						match it[pos][2]:
							"<": stack.push_back(l < r)
							"<=": stack.push_back(l <= r)
							">": stack.push_back(l > r)
							">=": stack.push_back(l >= r)
					else:
						incomp = true
				if incomp: _set_err_runtime(stack, it[pos], str("Incompatible types for binary op '", it[pos][2], "' (", type_string(typeof(l)), " and ", type_string(typeof(r)), ")"))
			Instruction.UNARY:
				var r = stack.pop_back()
				match it[pos][2]:
					"not":
						stack.push_back(r is Undefined or not r)
					"-":
						if r is Undefined: stack.push_back(Undefined.new(line))
						elif typeof(r) not in _TYPES_NUMBER: _set_err_runtime(stack, it[pos], str("Incompatible type for unary op '-' (", type_string(typeof(r)), ")"))
						else: stack.push_back(-r)
			Instruction.ASSIGN:
				var res = stack.pop_back()
				if _set_variable(it[pos][2], res): stack.push_back(res)
				else: stack.push_back(Undefined.new(line))
			Instruction.ASSIGN_IDX:
				var info = stack.pop_back() # obj, idx, lai
				var obj = info[0]
				var idx = info[1]
				var res = stack.back()
				if res is Undefined: res = null
				if obj is Array and (idx >= obj.size() or idx < -obj.size()): _set_err_runtime(stack, it[pos], str("Array access out of bounds (", idx, " of ", obj.size()))
				elif typeof(obj) in _TYPES_VECTORS:
					if typeof(res) not in _TYPES_NUMBER: _set_err_runtime(stack, it[pos], str("Trying to assign non-number, '", res, "' to structure member"))
					else:
						obj[idx] = res
						if info[2] and info[2] is Array: info[2][0][info[2][1]] = obj  # only necessary
						elif info[2] and info[2] is String: _set_variable(info[2], obj) # for structures!
				else: obj[idx] = res
			Instruction.PAIR:
				var value = stack.pop_back()
				var key = stack.pop_back()
				if _is_undefined(key): _set_err_runtime(stack, it[pos], "Undefined key for pair")
				else: stack.push_back(KeyValuePairProxy.new(key, value))
			Instruction.LITERAL:
				stack.push_back(it[pos][2])
			Instruction.POP:
				stack.pop_back()
				state.erase(&"lai")
			Instruction.IDENTIFIER:
				var res = _get_variable(it[pos][2])
				if res is Iterator: stack.push_back(res.get_cur_value())
				else: stack.push_back(_null_as_undef(res, line))
				state[&"lai"] = it[pos][2]
			Instruction.CHECK: # conditional jump
				var cond = stack.pop_back()
				var prev = stack.pop_back()
				if not cond or cond is Undefined:
					stack.push_back(prev)
					pos = it[pos][2] - 1
			Instruction.JUMP:
				pos = it[pos][2] - 1
			Instruction.INTERRUPT:
				state[&"interrupted"] = _undef_as_null(stack.pop_back())
			Instruction.CALL_METHOD:
				var obj = stack.pop_back() # get the object to access with a method
				var f: String = it[pos][2]
				if obj is Array: _excall(stack, line, it[pos], ArrayProxy.new(obj))
				elif obj is Dictionary: _excall(stack, line, it[pos], DictionaryProxy.new(obj))
				elif obj is Object: _excall(stack, line, it[pos], obj)
				else: _set_err_runtime(stack, it[pos], str("Invalid target object for method '", f, "'"))
			Instruction.CALL_INTERNAL:
				var rf: Expr.Function = _registered_in_funcs.get(it[pos][2])
				var fncall := [ pos ]
				if rf.params:
					var args := rf.params.duplicate(true)
					var keys: Array = args.keys()
					for i: int in it[pos][3]:
						if rf.is_variadic and i + 1 >= args.size(): args[keys[-1]].append(stack.pop_back())
						else: args[keys[i]] = stack.pop_back()
					fncall.append(args)
				fncalls.push_back(fncall)
				pos = rf.start_pos - 1
			Instruction.RETURN:
				var fncall: Array = fncalls.pop_back()
				pos = fncall[0]
			Instruction.CALL_EXTERNAL:
				var rf = _registered_ex_funcs.get(it[pos][2])
				_excall(stack, line, it[pos], target, rf)
			Instruction.CREATE_ARRAY:
				var res: Array; res.resize(it[pos][2])
				for i: int in it[pos][2]:
					var elem = stack.pop_back()
					res[i] = _undef_as_null(elem)
				stack.push_back(res)
			Instruction.CREATE_DICTIONARY:
				var res: Dictionary
				for i: int in it[pos][2]:
					var entry = stack.pop_back()
					if entry is KeyValuePairProxy: res[_undef_as_null(entry.key)] = _undef_as_null(entry.value)
					elif _is_undefined(entry): _set_err_runtime(stack, it[pos], "Undefined key for dictionary")
					else: res[entry] = null
				stack.push_back(res)
			Instruction.CREATE_STRUCTURE:
				var vars: Array = _TYPES_VECTORS.values()[_TOKEN_VECTORS.find(it[pos][2])]
				if it[pos][3] > vars.size(): _set_err_runtime(stack, it[pos], str("Too many arguments for '", it[pos][2], "'"))
				else:
					var init := []
					for i: int in it[pos][3]:
						var arg = stack.pop_back()
						if typeof(arg) not in _TYPES_NUMBER: _set_err_runtime(stack, it[pos], str("Wrong type for argument ", i + 1, " got ", type_string(typeof(arg)).to_lower())); break
						init.append(arg)
					if not err:
						for i: int in range(it[pos][3], vars.size()): init.append(0) # remaining arguments
						match it[pos][2]:
							"vector2": stack.push_back(Vector2(init[0], init[1]))
							"vector3": stack.push_back(Vector3(init[0], init[1], init[2]))
							"vector4": stack.push_back(Vector4(init[0], init[1], init[2], init[3]))
							"vector2i": stack.push_back(Vector2i(init[0], init[1]))
							"vector3i": stack.push_back(Vector3i(init[0], init[1], init[2]))
							"vector4i": stack.push_back(Vector4i(init[0], init[1], init[2], init[3]))
			Instruction.ACCESS_IDX:
				var idx = stack.pop_back()
				var obj = stack.pop_back()
				var tobj := typeof(obj)
				if tobj in _TYPES_INDEX_ACCESS:
					var is_str_or_arr := obj is Array or tobj in _TYPES_STRING
					if is_str_or_arr and typeof(idx) not in _TYPES_NUMBER: _set_err_runtime(stack, it[pos], str("Index access must be a number, is '", idx, "'"))
					elif is_str_or_arr and (idx >= len(obj) or idx < -len(obj)): _set_err_runtime(stack, it[pos], str("Index '", idx, "' out of bounds"))
					elif not it[pos][2] and obj is Dictionary and idx not in obj: _set_err_runtime(stack, it[pos], str("Dictionary key '", idx, "' invalid"))
					elif it[pos][2] and tobj in _TYPES_INDEX_ACCESS_LEFT_SIDE: stack.push_back([ obj, idx, state.get(&"lai", "") ]) # is left side
					elif it[pos][2] and tobj in _TYPES_STRING: _set_err_runtime(stack, it[pos], "Can't use String index access on left side")
					else: stack.push_back(obj[idx])
				elif tobj in _TYPES_VECTORS:
					if idx not in _TYPES_VECTORS[tobj]: _set_err_runtime(stack, it[pos], str("Vector key '", idx, "' invalid"))
					elif it[pos][2]: stack.push_back([ obj, idx, state.get(&"lai", "") ])  # is left side
					else: stack.push_back(obj[idx])
				else: _set_err_runtime(stack, it[pos], str("Invalid index access ", obj))
				if not err: state[&"lai"] = [ obj, idx ]
			Instruction.ITERATE:
				if str("$", it[pos][2]) in env:
					pos = it[pos][3] - 1 # not first iteration?
			Instruction.ITERATE_CONTINUE:
				var name := str("$", it[pos][2])
				var iter
				if name in env:
					iter = _get_variable(name, null, true)
				else:
					var obj = stack.pop_back()
					var ot := typeof(obj)
					if _is_undefined(obj): stack.push_back(Undefined.new(line))
					elif ot in _TYPES_NUMBER: iter = NumberIterator.new(obj)
					elif ot in _TYPES_STRING: iter = StringIterator.new(obj)
					elif ot in _TYPES_CONTAINER: iter = ContainerIterator.new(obj)
					else: _set_err_runtime(stack, it[pos], "Iterating via 'of' only possible over numbers, arrays, dictionaries and strings")
					if iter: _set_variable(name, iter, true)
				if iter:
					var res: bool = iter.iterate()
					if res: _set_variable(it[pos][2], iter.get_cur_value(), true)
					stack.push_back(res)
			Instruction.ITERATE_CLEAR:
				env.erase(str("$", it[pos][2]))
		pos += 1
		step += 1
		if max_steps > 0 and step >= max_steps:
			state[&"interrupted"] = null
	
	is_running = false
	state[&"stack"] = stack
	state[&"fncalls"] = fncalls
	state[&"pos"] = pos
	state[&"env"] = env
	state[&"step"] = step
	
	if err: printerr(err); return null
	
	if &"interrupted" in state:
		var res = state[&"interrupted"]
		state.erase(&"interrupted")
		return res
	
	if debug_printing and stack: print("RESULT: ", stack.back())
	if debug_printing: print("ENVIRONMENT: ", env)
	return stack.back() if stack else null

func _excall(stack: Array, line: int, it_at_pos: Array, t, rf = null) -> Variant:
	var res
	var mn: String = it_at_pos[2]
	if t is Object:
		var prefix = t.get(&"_mila_prefix")
		mn = str(prefix if typeof(prefix) in _TYPES_STRING else "_mila_", mn) # proxy call for safe object access
	if not rf and not (t and t.has_method(mn)): # check existence of method again - TODO always?
		_set_err_runtime(stack, it_at_pos, str("Method '", it_at_pos[2], "' not found"))
		return null
	var args = []
	var mlm = null if rf else t.get_method_list().filter(func(m: Dictionary) -> bool: return m.name == mn)[0]
	if not rf: # check argument count again - TODO always?
		if (mlm.flags & METHOD_FLAG_VARARG) == 0 and it_at_pos[3] > mlm.args.size():
			_set_err_runtime(stack, it_at_pos, str("Too many arguments for method '", mn, "'"))
		elif it_at_pos[3] < mlm.args.size() - mlm.default_args.size():
			_set_err_runtime(stack, it_at_pos, str("Too few arguments for method '", mn, "'"))
	if not err:
		for i: int in it_at_pos[3]:
			var arg = stack.pop_back()
			if arg is Undefined: arg = null
			var incomp := false
			if rf and i < rf[1].size():
				match rf[1][i]:
					T_ANY: pass
					T_NUMBER: if typeof(arg) not in _TYPES_NUMBER: incomp = true
					T_STRING: if typeof(arg) not in _TYPES_STRING: incomp = true
					T_UNDEFINED: if not _is_undefined(arg): incomp = true
					_: if typeof(arg) != rf[1][i]: incomp = true # using normal TYPE_* consts
				if incomp:
					_set_err_runtime(stack, it_at_pos, str("Incompatible type '", type_string(typeof(arg)).to_lower(), "' for parameter ", i + 1, ", wants '", rf[1][i], "'"))
					break
			elif mlm and i < mlm.args.size():
				match mlm.args[i].type:
					TYPE_INT, TYPE_FLOAT: if typeof(arg) not in _TYPES_NUMBER: incomp = true
					TYPE_STRING, TYPE_STRING_NAME: if typeof(arg) not in _TYPES_STRING: incomp = true
					TYPE_ARRAY: if arg is not Array: incomp = true
					_: if typeof(arg) != mlm.args[i].type and mlm.args[i].type != TYPE_NIL: incomp = true
				if incomp:
					_set_err_runtime(stack, it_at_pos, str("Incompatible type '", type_string(typeof(arg)).to_lower(), "' for parameter ", i + 1, ", wants '", type_string(mlm.args[i].type), "'"))
					break
			args.append(arg)
		if not err:
			if rf: res = rf[0].callv(args)
			else: res = t.callv(mn, args)
	stack.push_back(_null_as_undef(res, line))
	return res

func _get_variable(ident: String, default = null, global_only := false):
	if str("$", ident) in _cur_env: return _cur_env[ident] # iterator variable has precendence
	if not global_only:
		var fncalls = cur_state.get(&"fncalls")
		if fncalls and fncalls[-1].size() > 1:
			var fncall: Dictionary = fncalls[-1][1]
			if ident in fncall: return fncall[ident]
	return _cur_env.get(ident, default)

func _set_variable(ident: String, value, global_only := false) -> bool:
	if str("$", ident) in _cur_env: _cur_env[ident] = value; return true # iterator variable has precendence
	if not global_only:
		var fncalls = cur_state.get(&"fncalls")
		if fncalls and fncalls[-1].size() > 1:
			var fncall: Dictionary = fncalls[-1][1]
			if ident in fncall: fncall[ident] = value; return true
	if _is_undefined(value): _cur_env.erase(ident); return false
	_cur_env[ident] = value
	return true

###

func _set_err(e, overwrite := false) -> void:
	if err and not overwrite: return
	err = str(e)
	
func _set_err_runtime(stack: Array, instruction: Array, e: String) -> void:
	var error := str("[Runtime] [Line ", instruction[0], "] ", e)
	_set_err(error, false)
	stack.push_back(Undefined.new(instruction[0]))

func _null_as_undef(v, ln: int) -> Variant:
	return v if v != null else Undefined.new(ln)

func _undef_as_null(v) -> Variant:
	return v if v is not Undefined else null

func _is_undefined(obj) -> bool:
	return obj == null or obj is Undefined

### PROXIES

class Proxy:
	@warning_ignore("unused_private_class_variable") var _mila_prefix := "_proxy_"

class ArrayProxy extends Proxy:
	var array: Array
	# no filter, map, reduce
	func _init(a: Array) -> void: array = a
	func _to_string() -> String: return str(array)
	func _proxy_append(e) -> Array: array.append(e); return array
	func _proxy_append_array(a: Array) -> Array: array.append_array(a); return array
	func _proxy_assign(a: Array) -> Array: array.assign(a); return array
	func _proxy_back() -> Variant: return array[-1] if array else null
	func _proxy_bsearch(val, before := true) -> int: return array.bsearch(val, before)
	func _proxy_clear() -> Array: array.clear(); return array
	func _proxy_count(val) -> int: return array.count(val)
	func _proxy_duplicate(deep := false) -> Array: return array.duplicate(deep)
	func _proxy_erase(val) -> Array: array.erase(val); return array
	func _proxy_fill(val) -> Array: array.fill(val); return array
	func _proxy_find(val, from := 0) -> int: return array.find(val, from)
	func _proxy_front() -> Variant: return array[0] if array else null
	func _proxy_get(idx: int) -> Variant: return array[idx] if idx < array.size() and idx >= -array.size() else null
	func _proxy_has(val) -> bool: return val in array
	func _proxy_hash() -> int: return array.hash()
	func _proxy_insert(idx: int, val) -> Array: array.insert(idx, val); return array # TODO error check?
	func _proxy_is_empty() -> bool: return array.is_empty()
	func _proxy_max() -> Variant: return array.max()
	func _proxy_min() -> Variant: return array.min()
	func _proxy_pick_random() -> Variant: return array.pick_random()
	func _proxy_pop_at(idx: int) -> Variant: return array.pop_at(idx) if idx < array.size() and idx >= -array.size() else null
	func _proxy_pop_back() -> Variant: return array.pop_back()
	func _proxy_pop_front() -> Variant: return array.pop_front()
	func _proxy_push_back(val) -> Array: array.push_back(val); return array
	func _proxy_push_front(val) -> Array: array.push_front(val); return array
	func _proxy_remove_at(idx: int) -> Array:
		if idx < array.size() and idx >= -array.size(): array.remove_at(idx);
		return array
	func _proxy_resize(sz: int) -> Array: array.resize(sz); return array
	func _proxy_reverse() -> Array: array.reverse(); return array
	func _proxy_rfind(val, from := 0) -> int: return array.rfind(val, from)
	func _proxy_set(idx: int, val) -> Array:
		if idx < array.size() and idx >= -array.size(): array[idx] = val
		return array
	func _proxy_shuffle() -> Array: array.shuffle(); return array
	func _proxy_size() -> int: return array.size()
	func _proxy_slice(begin: int, end := 0x7FFFFFFF, step := 1, deep := false) -> Array: return array.slice(begin, end, step, deep)
	func _proxy_sort() -> Array: array.sort(); return array

class DictionaryProxy extends Proxy:
	var dict: Dictionary
	func _init(d: Dictionary) -> void: dict = d
	func _to_string() -> String: return str(dict)
	func _proxy_assign(d: Dictionary) -> Dictionary: dict.assign(d); return dict
	func _proxy_clear() -> Dictionary: dict.clear(); return dict
	func _proxy_duplicate(deep := false) -> Dictionary: return dict.duplicate(deep)
	func _proxy_erase(key) -> Dictionary: dict.erase(key); return dict
	func _proxy_find_key(val) -> Variant: return dict.find_key(val)
	func _proxy_get(key, default = null) -> Variant: return dict.get(key, default)
	func _proxy_get_or_add(key, default = null) -> Variant: return dict.get_or_add(key, default)
	func _proxy_has(key) -> bool: return dict.has(key)
	func _proxy_has_all(keys: Array) -> bool: return dict.has_all(keys)
	func _proxy_hash() -> int: return dict.hash()
	func _proxy_is_empty() -> bool: return dict.is_empty()
	func _proxy_keys() -> Array: return dict.keys()
	func _proxy_merge(d: Dictionary, overwrite := false) -> Dictionary: dict.merge(d, overwrite); return dict
	func _proxy_merged(d: Dictionary, overwrite := false) -> Dictionary: return dict.merged(d, overwrite)
	func _proxy_recursive_equal(d: Dictionary, recursion_count := 100) -> bool: return dict.recursive_equal(d, recursion_count)
	func _proxy_set(entry) -> Dictionary:
		if entry is KeyValuePairProxy: dict.set(entry.key, entry.value)
		else: dict.set(entry, null)
		return dict # changes argument and return value of set()
	func _proxy_size() -> int: return dict.size()
	func _proxy_sort() -> Dictionary: dict.sort(); return dict
	func _proxy_values() -> Array: return dict.values()

class KeyValuePairProxy extends Proxy:
	var key
	var value
	func _init(k, v) -> void: key = k; value = v
	func _to_string() -> String: return str("(", key, ": ", value, ")")
	func _proxy_key() -> Variant: return key
	func _proxy_value() -> Variant: return value

###

class Iterator:
	var target
	var cur_idx := -1
	func _init(t) -> void: target = t
	func _to_string() -> String: return str(get_cur_value())
	func iterate() -> bool: return false
	func get_cur_value() -> Variant: return null

class NumberIterator extends Iterator:
	func iterate() -> bool:
		cur_idx += 1
		return cur_idx < target
	func get_cur_value() -> Variant:
		return cur_idx

class StringIterator extends Iterator:
	func iterate() -> bool:
		cur_idx += 1
		return cur_idx < len(target)
	func get_cur_value() -> Variant:
		if not target or cur_idx < 0 or cur_idx >= len(target): return null
		return target[cur_idx]

class ContainerIterator extends StringIterator:
	func _init(t) -> void: target = t.keys() if t is Dictionary else t

### LEXER

func _lex(code: String) -> Array[Array]:
	var pos := 0
	var tokens: Array[Array] = []
	var reg := RegEx.new()
	var line := 1
	var code_len := code.length()
	while pos < code_len:
		var res: RegExMatch = null
		var tag: String
		for tidx: int in range(0, _TOKEN_EXPRESSIONS.size(), 2):
			reg.compile(_TOKEN_EXPRESSIONS[tidx])
			res = reg.search(code, pos)
			if res and res.get_start() == pos:
				tag = _TOKEN_EXPRESSIONS[tidx + 1]
				var value := res.get_string()
				if tag == _IGNORE:
					line += value.count("\n")
					break
				if tag == _ID:
					if value in _TOKEN_KEYWORDS: tag = _RESERVED
					elif value in _TOKEN_BOOLS: tag = _BOOL
					elif value in _TOKEN_CONTAINERS or value in _TOKEN_VECTORS: tag = _OBJECT
					elif value in _TOKEN_UNDEFINED: tag = _UNDEFINED
					elif res.get_end() < code_len and code[res.get_end()] == "(": tag = _ID_FUNC
				tokens.append([ value, tag, line ])
				break
			else:
				res = null
		if res: pos = res.get_end()
		else: _set_err(str("[Lexer] [Line ", line, "] Found illegal character '", code[pos], "' (token ", pos, ")")); return []
	return tokens

### EXPRESSIONS

class Undefined extends Expr:
	func _to_string() -> String: return "undefined"
	func compile(_mila: Mila, it: Array[Array], _scope_stack: Array[Scope], _parent: Expr = null) -> void: it.append([ _line, Instruction.UNDEFINED ])

class Scope:
	var start_pos: int
	var stops: Array[Array]
	var is_func: bool
	func _init(p: int, f := false) -> void: start_pos = p; is_func = f
	func init_stops(p: int) -> void: for s: Array in stops: s.append(p) # jump targets of stops

class Expr:
	var _line: int
	
	func _set_err(mila: Mila, e: String) -> void:
		var error := str("[Compiler] [Line ", _line, "] ", e)
		mila._set_err(error, false)
		
	func _init(l: int) -> void:
		_line = l
	
	func compile(_mila: Mila, _it: Array[Array], _scope_stack: Array[Scope], _parent: Expr = null) -> void:
		pass
	
	# TODO make the operations more robust for different types
	class Binary extends Expr:
		var left: Expr
		var op: String
		var right: Expr
		func _init(ln: int, l: Expr, o: String, r: Expr) -> void: super(ln); left = l; op = o; right = r
		func _to_string() -> String: return str("Binary(", left, ", '", op, "', ", right, ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			if left == null: _set_err(mila, str("Binary op '", op, "' missing left operand")); return
			if right == null: _set_err(mila, str("Binary op '", op, "' missing right operand")); return
			if op == "and" or op == "or":
				left.compile(mila, it, scope_stack)
				var d = [ _line, Instruction.BINARY_LOGIC, op ]; it.append(d)
				right.compile(mila, it, scope_stack)
				it.append([ _line, Instruction.BINARY_LOGIC_END ])
				d.append(it.size())
			else:
				left.compile(mila, it, scope_stack)
				right.compile(mila, it, scope_stack)
				it.append([ _line, Instruction.BINARY, op ])
	class Unary extends Expr:
		var op: String
		var right: Expr
		func _init(ln: int, o: String, r: Expr) -> void: super(ln); op = o; right = r
		func _to_string() -> String: return str("Unary('", op, "', ", right, ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			right.compile(mila, it, scope_stack)
			it.append([ _line, Instruction.UNARY, op ])
	class Accessor extends Expr:
		var left: Expr
		var right: Expr
		func _init(ln: int, l: Expr, r: Expr) -> void: super(ln); left = l; right = r
		func _to_string() -> String: return str("Accessor(", left, ", ", right, ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			if left == null: _set_err(mila, "Accessor missing left operand"); return
			if right == null: _set_err(mila, "Accessor missing right operand"); return
			right.compile(mila, it, scope_stack, left)
	class Iterate extends Expr:
		var ident: Identifier
		var expr: Expr
		func _init(ln: int, i: Identifier, e: Expr) -> void: super(ln); ident = i; expr = e
		func _to_string() -> String: return str("Iterate(", ident, ", ", expr, ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			var skip_check := [ _line, Instruction.ITERATE, ident.name ]; it.append(skip_check)
			expr.compile(mila, it, scope_stack)
			skip_check.append(it.size())
			it.append([ _line, Instruction.ITERATE_CONTINUE, ident.name ])
	class Assignment extends Expr:
		var left: Expr
		var op: String
		var right: Expr
		func _init(ln: int, l: Expr, o: String, r: Expr) -> void: super(ln); left = l; op = o; right = r
		func _to_string() -> String: return str("Assignment(", left, ", '", op, "', ", right, ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			right.compile(mila, it, scope_stack)
			if left is Expr.Identifier: it.append([ _line, Instruction.ASSIGN, left.name ])
			elif left is Expr.IdxAccess: left.compile(mila, it, scope_stack); it.append([ _line, Instruction.ASSIGN_IDX ])
	class Pair extends Expr:
		var key: Expr
		var value: Expr
		func _init(ln: int, k: Expr, v: Expr) -> void: super(ln); key = k; value = v
		func _to_string() -> String: return str("Pair(", key, ", ", value, ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			key.compile(mila, it, scope_stack)
			value.compile(mila, it, scope_stack)
			it.append([ _line, Instruction.PAIR ])
	class Literal extends Expr:
		var lit
		func _init(ln: int, l) -> void: super(ln); lit = l
		func _to_string() -> String: return str("Literal(", lit, ", ", type_string(typeof(lit)), ")")
		func compile(_mila: Mila, it: Array[Array], _scope_stack: Array[Scope], _parent: Expr = null) -> void:
			it.append([ _line, Instruction.LITERAL, lit ])
	class List extends Expr:
		var exprs: Array[Expr]
		func _init(ln: int, a: Array[Expr]) -> void: super(ln); exprs = a
		func _to_string() -> String: return str("List(", exprs.map(func(i) -> Variant: return i), ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			var p := 0
			for i: int in exprs.size():
				if exprs[i] is not Function:
					if p != 0: it.append([ _line, Instruction.POP ])
					p += 1
				exprs[i].compile(mila, it, scope_stack)
	class Identifier extends Expr:
		var name: String
		func _init(ln: int, n: String) -> void: super(ln); name = n
		func _to_string() -> String: return str("Identifier('", name, "')")
		func compile(_mila: Mila, it: Array[Array], _scope_stack: Array[Scope], _parent: Expr = null) -> void:
			it.append([ _line, Instruction.IDENTIFIER, name ])
		func cloned() -> Identifier: return Identifier.new(_line, name)
	class If extends Expr:
		var conds: Array[Expr]
		var bodies: Array[Expr]
		func _init(ln: int, c: Array[Expr], b: Array[Expr]) -> void: super(ln); conds = c; bodies = b
		func _to_string() -> String: return str("If(", conds, ", ", bodies.map(func(i) -> Variant: return i), ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			var jumps: Array[Array]
			it.append([ _line, Instruction.UNDEFINED ])
			for i: int in conds.size():
				conds[i].compile(mila, it, scope_stack)
				var check := [ _line, Instruction.CHECK ]; it.append(check)
				if bodies[i]: bodies[i].compile(mila, it, scope_stack)
				else: it.append([ _line, Instruction.UNDEFINED ])
				jumps.append([ _line, Instruction.JUMP ]); it.append(jumps[-1])
				check.append(it.size())
			if bodies.size() > conds.size():
				if bodies[-1]: bodies[-1].compile(mila, it, scope_stack)
				else: it.append([ _line, Instruction.UNDEFINED ])
			for j in jumps:
				j.append(it.size())
	class While extends Expr:
		var cond: Expr
		var body: Expr
		func _init(ln: int, c: Expr, b: Expr) -> void: super(ln); cond = c; body = b
		func _to_string() -> String: return str("While(", cond, ", ", body, ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			it.append([ _line, Instruction.UNDEFINED ])
			var start_pos := it.size()
			var scope := Scope.new(start_pos)
			scope_stack.push_back(scope)
			cond.compile(mila, it, scope_stack)
			var check := [ _line, Instruction.CHECK ]; it.append(check)
			if body: body.compile(mila, it, scope_stack)
			else: it.append([ _line, Instruction.UNDEFINED ])
			it.append([ _line, Instruction.JUMP, start_pos ])
			check.append(it.size())
			scope.init_stops(it.size())
			scope_stack.erase(scope)
			if cond is Expr.Iterate: it.append([ _line, Instruction.ITERATE_CLEAR, cond.ident.name ])
	class FlowControl extends Expr:
		var with: Expr
		var op: String
		func _init(ln: int, o: String, w: Expr) -> void: super(ln); op = o; with = w
		func _to_string() -> String: return str("FlowControl(", op, str(" with ", with, ")") if with else ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			if op == "interrupt":
				if with: with.compile(mila, it, [])
				else: it.append([ _line, Instruction.UNDEFINED ])
				it.append([ _line, Instruction.INTERRUPT ])
			elif not scope_stack:
				_set_err(mila, "Unexpected '" + op + "'")
			else:
				var jump := [ _line, Instruction.JUMP ]
				if with: with.compile(mila, it, [])
				else: it.append([ _line, Instruction.UNDEFINED ])
				if op == "stop": scope_stack.back().stops.append(jump)
				elif op == "skip": jump.append(scope_stack.back().start_pos)
				else: # exit
					var idx := 0
					for i in range(1, scope_stack.size() + 1): if scope_stack[-i].is_func: idx = -i; break
					scope_stack[idx].stops.append(jump)
				it.append(jump)
	class Function extends Expr:
		var body: Expr
		var start_pos: int
		var params: Dictionary
		var is_variadic: bool
		func _init(ln: int, b: Expr, p: Array[Expr.Identifier]) -> void:
			super(ln); body = b
			for i: int in p.size():
				if p[i]: params[p[i].name] = null
				else: params[p[i - 1].name] = []; is_variadic = true
		func _to_string() -> String: return str("Function(", body, ", ", params, ")")
		func compile_deferred(mila: Mila, it: Array[Array]) -> void:
			start_pos = it.size()
			var scope := Scope.new(start_pos, true)
			if body: body.compile(mila, it, [ scope ])
			else: it.append([ _line, Instruction.UNDEFINED ])
			scope.init_stops(it.size())
			it.append([ _line, Instruction.RETURN ])
	class FnCall extends Expr:
		var method: String
		var args: Array[Expr]
		func _init(ln: int, m: String, a: Array[Expr]) -> void: super(ln); method = m; args = a
		func _to_string() -> String: return str("FnCall('", method, "', ", args.map(func(i) -> Variant: return i), ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], parent: Expr = null) -> void:
			if parent:
				# method calls can't validate argument count during compilation
				for i: int in range(args.size() - 1, -1, -1): args[i].compile(mila, it, scope_stack)
				parent.compile(mila, it, scope_stack)
				it.append([ _line, Instruction.CALL_METHOD, method, args.size() ])
			else:
				var rf = mila._registered_in_funcs.get(method)
				var res
				if rf: # internal call
					if not rf.is_variadic and args.size() > rf.params.size(): _set_err(mila, str("Too many arguments for function '", method, "'"))
					else: res = [ _line, Instruction.CALL_INTERNAL, method, args.size() ]
				else:
					rf = mila._registered_ex_funcs.get(method)
					if rf: # external call
						if not rf[3] and args.size() > rf[1].size(): _set_err(mila, str("Too many arguments for function '", method, "'"))
						elif args.size() < rf[1].size() - rf[2]: _set_err(mila, str("Too few arguments for function '", method, "'"))
						else: res = [ _line, Instruction.CALL_EXTERNAL, method, args.size() ]
					elif mila.target: # target method call
						var prefix = mila.target.get(&"_mila_prefix")
						var mn = str(prefix if prefix is String or prefix is StringName else "_mila_", method)
						if not mila.target.has_method(mn): _set_err(mila, str("Invalid function '", method, "', does not exist"))
						else:
							var f: Dictionary = mila.target.get_method_list().filter(func(m: Dictionary) -> bool: return m.name == mn)[0]
							if (f.flags & METHOD_FLAG_VARARG) == 0 and args.size() > f.args.size(): _set_err(mila, str("Too many arguments for function '", method, "'"))
							elif args.size() < f.args.size() - f.default_args.size(): _set_err(mila, str("Too few arguments for function '", method, "'"))
							else: res = [ _line, Instruction.CALL_EXTERNAL, method, args.size() ]
					else:
						_set_err(mila, str("Invalid usage of function call for '", method, "'"))
				if res:
					for i: int in range(args.size() - 1, -1, -1): args[i].compile(mila, it, scope_stack)
					it.append(res)
	class CreateContainer extends Expr:
		var type: String
		var params: Array[Expr]
		func _init(ln: int, t: String, p: Array[Expr]) -> void: super(ln); type = t; params = p
		func _to_string() -> String: return str("CreateContainer(", type.capitalize(), ", ", params.map(func(i) -> Variant: return i), ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			for i: int in range(params.size() - 1, -1, -1):
				params[i].compile(mila, it, scope_stack)
			var instr: Instruction = [ Instruction.CREATE_ARRAY, Instruction.CREATE_DICTIONARY ][_TOKEN_CONTAINERS.find(type)]
			it.append([ _line, instr, params.size() ])
	class CreateStructure extends Expr:
		var type: String
		var params: Array[Expr]
		func _init(ln: int, t: String, p: Array[Expr]) -> void: super(ln); type = t; params = p
		func _to_string() -> String: return str("CreateStructure(", type.capitalize(), ", ", params.map(func(i) -> Variant: return i), ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			for i: int in range(params.size() - 1, -1, -1):
				params[i].compile(mila, it, scope_stack)
			it.append([ _line, Instruction.CREATE_STRUCTURE, type, params.size() ])
	class IdxAccess extends Expr:
		var obj: Expr
		var idx
		var is_left_side := false
		func _init(ln: int, o: Expr, i) -> void: super(ln); obj = o; idx = i
		func _to_string() -> String: return str("IdxAccess(", obj, ", ", idx if idx is Expr else str("'", idx, "'"), ")")
		func compile(mila: Mila, it: Array[Array], scope_stack: Array[Scope], _parent: Expr = null) -> void:
			obj.compile(mila, it, scope_stack)
			if idx is Expr: idx.compile(mila, it, scope_stack)
			else: it.append([ _line, Instruction.LITERAL, idx ])
			it.append([ _line, Instruction.ACCESS_IDX, is_left_side ])
		func cloned() -> IdxAccess: return IdxAccess.new(_line, obj, idx) # without is_left_side!

### PARSER

class Parser:
	var mila: Mila
	var tokens: Array[Array]
	var exprs: Array[Expr]
	var pos := 0
	var _err_pos := 0
	
	func _init(m: Mila, t: Array[Array]) -> void:
		mila = m
		tokens = t
	
	func _set_err(e: String) -> void:
		var error := str("[Parser] [Line ", tokens[mini(_err_pos, tokens.size() - 1)][2], "] ", e)
		mila._set_err(error, false)
	
	func expressions(expected_reserved = null) -> Expr:
		var expr: Expr = null
		var array: Array[Expr]
		var ln: int = tokens[pos][2]
		while pos < tokens.size():
			if expected_reserved and tokens[pos][0] in expected_reserved: break
			var e := expression()
			if mila.err: return null
			if not e: break
			array.append(e)
			expr = e
		return Expr.List.new(ln, array) if array.size() > 1 else expr
	
	func expression() -> Expr:
		return assignment()
	
	func assignment() -> Expr:
		var expr := pair()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_ASSIGNMENT:
			if expr is not Expr.Identifier and expr is not Expr.IdxAccess:
				_set_err("Assignment missing left side identifier"); return null
			elif expr is Expr.IdxAccess:
				expr.is_left_side = true
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := expression()
			if not right: _set_err("Assignment missing right side expression"); return null
			if operator == "=": expr = Expr.Assignment.new(ln, expr, operator, right)
			else: expr = Expr.Assignment.new(ln, expr, operator, Expr.Binary.new(ln, expr.cloned(), operator.replace("=", ""), right))
		return expr
	
	func pair() -> Expr:
		var expr := op_and()
		if pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] == _TOKEN_PAIR:
			var ln: int = tokens[pos][2]
			pos += 1
			var value := expression()
			if not value: _set_err("Pair missing value expression"); return null
			expr = Expr.Pair.new(ln, expr, value)
		return expr
	
	func op_and() -> Expr:
		var expr := op_or()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_AND:
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := op_or()
			if not right: _set_err("Binary op 'and' has wrong right side"); return null
			expr = Expr.Binary.new(ln, expr, operator, right)
		return expr
	
	func op_or() -> Expr:
		var expr := equality()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_OR:
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := equality()
			if not right: _set_err("Binary op 'or' has wrong right side"); return null
			expr = Expr.Binary.new(ln, expr, operator, right)
		return expr
	
	func equality() -> Expr:
		var expr := comparison()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_EQUALITY:
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := comparison()
			if not right: _set_err("Binary op '" + operator + "' has wrong right side"); return null
			expr = Expr.Binary.new(ln, expr, operator, right)
		return expr
	
	func comparison() -> Expr:
		var expr := term()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_COMPARISON:
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := term()
			if not right: _set_err("Binary op '" + operator + "' has wrong right side"); return null
			expr = Expr.Binary.new(ln, expr, operator, right)
		return expr
	
	func term() -> Expr:
		var expr := factor()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_TERM:
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := factor()
			if not right: _set_err("Binary op '" + operator + "' has wrong right side"); return null
			expr = Expr.Binary.new(ln, expr, operator, right)
		return expr
	
	func factor() -> Expr:
		var expr := unary()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_FACTOR:
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := unary()
			if not right: _set_err("Binary op '" + operator + "' has wrong right side"); return null
			expr = Expr.Binary.new(ln, expr, operator, right)
		return expr
	
	func unary() -> Expr:
		if pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] in _TOKEN_UNARY:
			var ln: int = tokens[pos][2]
			var operator: String = tokens[pos][0]
			pos += 1
			var right := unary()
			if not right: _set_err("Unary op '" + operator + "' has wrong right side"); return null
			return Expr.Unary.new(ln, operator, right)
		return accessor()
	
	func accessor() -> Expr:
		var expr := index_access()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] == _TOKEN_ACCESS:
			var ln: int = tokens[pos][2]
			pos += 1
			var right := primary()
			if not right or right is Expr.Literal: _set_err("Access operator has wrong right side"); return null
			elif right is Expr.Identifier: expr = Expr.IdxAccess.new(ln, expr, right.name)
			else: expr = Expr.Accessor.new(ln, expr, right)
		return expr
	
	func index_access() -> Expr:
		var expr := primary()
		while pos < tokens.size() and tokens[pos][1] == _RESERVED and tokens[pos][0] == "[":
			var ln: int = tokens[pos][2]
			pos += 1
			var idx := expression()
			if not idx: _set_err("Expect expression inside array access")
			elif pos >= tokens.size(): _set_err("Expect ']' after expression, early EOF")
			elif tokens[pos][0] != "]": _set_err("Expect ']' after expression")
			else: pos += 1; expr = Expr.IdxAccess.new(ln, expr, idx)
		return expr

	func primary() -> Expr:
		var tcount := tokens.size()
		if pos >= tcount: return null
		var res: Expr = null
		_err_pos = pos
		var tkn = tokens[pos][0]
		var ln: int = tokens[pos][2]
		match tokens[pos][1]:
			_UNDEFINED: res = Undefined.new(ln)
			_BOOL: res = Expr.Literal.new(ln, tkn == "true")
			_FLOAT: res = Expr.Literal.new(ln, float(tkn))
			_INT: res = Expr.Literal.new(ln, int(tkn))
			_STRING: res = Expr.Literal.new(ln, tkn.substr(1, tkn.length() - 2).c_unescape()) # removing the quotation marks
			_ID: res = Expr.Identifier.new(ln, tkn)
			_ID_FUNC:
				var group = _group("arguments")
				if not mila.err: res = Expr.FnCall.new(ln, tkn, group)
			_OBJECT:
				if tkn in _TOKEN_CONTAINERS:
					var group = _group(tkn + " elements")
					if group == null: _set_err("Expect '(' after '" + tkn + "'")
					else: res = Expr.CreateContainer.new(ln, tkn, group)
				elif tkn in _TOKEN_VECTORS:
					var group = _group(tkn + " elements")
					if group == null: _set_err("Expect '(' after '" + tkn + "'")
					else: res = Expr.CreateStructure.new(ln, tkn, group)
				else:
					_set_err("Unexpected keyword '" + tkn + "'")
					pos += 1
			_RESERVED:
				if tkn == "(":
					pos += 1
					var expr := expression()
					if not expr: _set_err("Expect expression inside group")
					elif pos >= tcount: _set_err("Expect ')' after expression, early EOF")
					elif tokens[pos][0] != ")": _set_err("Expect ')' after expression")
					else: res = expr
				elif tkn == "if":
					var conds: Array[Expr]
					var bodies: Array[Expr]
					var expected := "if"
					while tokens[pos][0] == expected:
						pos += 1
						var cond := expression()
						if not cond: _set_err("Expect condition after '" + expected + "'"); break
						elif pos >= tcount: _set_err("Expect 'then' after '" + expected + "' condition, early EOF"); break
						elif tokens[pos][0] != "then": _set_err("Expect 'then' after '" + expected + "' condition"); break
						conds.append(cond)
						pos += 1
						var body := expressions([ "elif", "else", "end" ])
						if pos >= tcount: _set_err("Expect 'elif', 'else' or 'end' after " + expected + "-body, early EOF"); break
						bodies.append(body)
						expected = "elif"
					if pos < tcount and tokens[pos][0] == "else":
						pos += 1
						var body_else := expressions([ "end" ])
						if pos >= tcount : _set_err("Expect 'end' after else-body, early EOF")
						else: bodies.append(body_else)
					if not mila.err:
						res = Expr.If.new(ln, conds, bodies)
				elif tkn == "while":
					pos += 1
					var first := expression()
					if not first: _set_err("Expect condition or iterator after 'while'")
					else:
						if pos >= tcount: _set_err("Expect 'of' or 'do' after 'while' expression, early EOF")
						elif tokens[pos][0] == "of":
							if first is not Expr.Identifier: _set_err("Expect identifier before keyword 'of'")
							else:
								pos += 1
								var right := expression()
								if not right: _set_err("Expect expression after keyword 'of'")
								elif tokens[pos][0] != "do": _set_err("Expect 'do' after 'while' expression")
								else: first = Expr.Iterate.new(tokens[pos][2], first, right)
						if not mila.err:
							if tokens[pos][0] != "do": _set_err("Expect 'of' or 'do' after 'while' expression")
							else:
								pos += 1
								var body := expressions([ "end" ])
								if pos >= tcount: _set_err("Expect 'end' after while-body, early EOF")
								else: res = Expr.While.new(ln, first, body)
				elif tkn in _TOKEN_FLOW_CONTROL:
					var with: Expr
					if pos < tcount - 1 and tokens[pos + 1][0] == "with":
						pos += 2
						with = expression()
						if not with: _set_err("Expect expression after 'with'")
						else: pos -= 1
					if not mila.err:
						res = Expr.FlowControl.new(ln, tkn, with)
				elif tkn == "function":
					pos += 1
					if pos >= tcount: _set_err("Expect identifier after 'function', early EOF")
					elif tokens[pos][1] not in [ _ID, _ID_FUNC ]: _set_err("Expect identifier after 'function'")
					else:
						var ident: String = tokens[pos][0]
						if ident in mila._registered_in_funcs: _set_err(str("Double definition of function '", ident, '"'))
						else:
							var params = _group_parameters("function parameters")
							if params == null: _set_err("Expect '(' after function identifier)")
							else:
								pos += 1
								var body := expressions([ "end" ])
								if pos >= tcount: _set_err("Expect 'end' after function-body, early EOF")
								else:
									res = Expr.Function.new(ln, body, params)
									mila._registered_in_funcs[ident] = res
				else:
					_set_err("Unexpected keyword '" + tkn + "'")
					pos += 1
		if res: pos += 1
		return res
	
	func _group(name: String) -> Variant: # returns Array[Expr] or null 
		var tcount := tokens.size()
		if pos < tcount - 1 and tokens[pos + 1][0] == "(":
			pos += 2
			var group: Array[Expr] = []
			if tokens[pos][0] != ")":
				while pos < tcount:
					var expr := expression()
					if not expr: _set_err("Expect expression in " + name); break
					group.append(expr)
					if pos >= tcount: _set_err("Expect ',' or ')' in " + name + ", early EOF"); break
					elif tokens[pos][0] == ",": pos += 1
					elif tokens[pos][0] != ")": _set_err("Expect ',' or ')' in " + name); break
					else: break
			if not mila.err:
				if pos >= tcount: _set_err("Expect expression in " + name + ", early EOF")
				else: return group
		return null
	
	func _group_parameters(name: String) -> Variant:
		var tcount := tokens.size()
		if pos < tcount - 1 and tokens[pos + 1][0] == "(":
			pos += 2
			var group: Array[Expr.Identifier] = []
			if tokens[pos][0] != ")":
				while pos < tcount:
					var ident := primary()
					if ident is not Expr.Identifier: _set_err("Expect identifier in " + name); break
					elif group.any(func(i: Expr.Identifier) -> bool: return i.name == ident.name): _set_err("Expect unique identifiers in " + name); break
					group.append(ident)
					if pos >= tcount: _set_err("Expect ',' or '...' or ')' in " + name + ", early EOF")
					elif tokens[pos][0] == ",": pos += 1; continue
					elif tokens[pos][0] == "...":
						pos += 1; group.append(null) # is variadic
						if tokens[pos][0] != ")": _set_err("Expect ')' after '...' in " + name)
					elif tokens[pos][0] != ")": _set_err("Expect ',' or '...' or ')' in " + name)
					break
			if not mila.err:
				if pos >= tcount: _set_err("Expect identifier in " + name + ", early EOF")
				else: return group
		return null

	func parse() -> Expr:
		var res := expressions()
		if mila.err: return null
		return res

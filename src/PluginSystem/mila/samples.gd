extends Node

### methods used by mila.gd - prefixed with "_mila_"

func _mila_func_1():
	print("Function call test 1 - called a function without parameters")

func _mila_func_2(a, b, c := "optional param"):
	prints("Function call test 2 -", a, b, c)
	return "return value from func_2"

func _mila_func_3() -> Array:
	return [ 1, 2, 3 ]

func _mila_print(...args) -> String: # variadic functions are allowed too
	var p := " ".join(args)
	print("Script prints '", p, "'")
	return str(p)

###

func _ready() -> void:
	var m := Mila.new(self)
	var res
	
	#m.debug_printing = true
	
	# test calling GDScript functions
	res = m.eval('
		print("Variadic functions", "are allowed!", 123)
		func_1()
		func_2("foo", ifif)
		// not allowed due to whitespace: func_1 ()
	')
	print("RESULT 1 (external func call): ", res, "\n") # "return value from func_2"
	assert(res is String and res == "return value from func_2", "Result 1 wrong")
	
	# test factorial code
	res = m.eval('
		n = 5 // no ; needed, or even line-breaks
		p = 1
		while n > 0 do
			p *= n // compound assignments +=, -=, *=, /= and %= are supported
			n -= 1
		end
		p // the last expression is the result of the eval() call
	')
	print("RESULT 2 (factorial): ", res, "\n") # 120
	assert((res is int or res is float) and res == 120, "Result 2 wrong")
	
	# test custom env Dictionary, and some assignments
	var env := { "test": "str" }
	res = m.eval('
		// test is defined already through the env Dictionary
		t = if test != "str" then 100 else 50 end // if-then-elif-then-else and while-do can be used as expressions
		r = s = -5 // assignments are expressions too
		w = false
		r = undefined // r will be removed from env!
		t - 50 == 0
	', env)
	print("RESULT 3 (custom env): ", res) # true
	print("-> WITH ENVIRONMENT: ", env, "\n")
	assert((res is bool) and res == true and "r" not in env, "Result 3 wrong")
	
	# test undefined (similar to null in GDScript)
	res = m.eval('
		y = if 1 + 1 == 3 then "y is undefined because this if-expression returns null" end
		if y == undefined then print("y is not defined") end
		y // will return undefined
	')
	print("RESULT 4 (undefined): ", res, "\n") # undefined
	assert(res is Object and res is Mila.Undefined, "Result 4 wrong")
	
	# test conditions, skip and stop
	res = m.eval('
		x = -1
		while x < 10 do
			x += 1
			if x == 3 then
				print("no three for thee")
				skip
			elif x == 6 then
				stop with x // the "with" part is optional
			end
			print(x)
		end
	')
	print("RESULT 5 (condition, skip, stop): ", res, "\n") # 6
	assert((res is int or res is float) and res == 6, "Result 5 wrong")
	
	# test string stuff
	res = m.eval('
		print("hello world" - "lo ") // subtracting removes the word(s)
		print("hello " * 3 + "world") // multiplying repeats the word
		"number test: " + 3.141 + " " + 1000
	')
	print("RESULT 6: ", res, "\n") # number test: 3.141 1000
	assert((res is String) and res == "number test: 3.141 1000", "Result 6 (string stuff) wrong")
	
	# test function
	res = m.eval('
		x = 3 y = 5
		sum()
		sum()
		
		function sum()
			x = x + y
			print("sum: " + x)
			x
		end
	')
	print("RESULT 7 (internal func): ", res, "\n") # 13
	assert((res is int or res is float) and res == 13, "Result 7 wrong")
	
	# test endless loop and max steps of code execution
	var max_steps := 185
	var state := {} # could also use g.cur_state for this
	for i in 10:
		# this compiles the code again on every step, which is wasteful - better use g.run() instead
		res = m.eval('
			x = 0
			while true do
				x = x + 1
				if x > 100 then
					interrupt with x // premature script exit
				end
			end', null, state, max_steps)
		print("value of X on frame ", i, ": ", state.env["x"], " after ", state["step"], " steps")
		await get_tree().process_frame
	print("RESULT 8 (endless loop and interrupt): ", res, "\n")
	assert((res is int or res is float) and res == 103, "Result 8 wrong")
	
	# test calling mila.gd functions
	res = m.eval('
		function test()
			print("inside function test()")
			if x == 0 then exit // use exit like "return" in other langs
			elif x == 1 then 5
			else 7 end
		end
		print("outside function test()")
		x = 1
		test()
	', null, null, 200)
	print("RESULT 9 (internal func): ", res, "\n")
	assert((res is int or res is float) and res == 5, "Result 9 wrong")
	
	# Attention: `g` keeps the `function test()` when the next call of `m.eval()` has the `clear_internal_funcs`
	# parameter set to `false` (default is `true`) - this way you could reuse it
	
	# test calling mila.gd functions recursively
	res = m.eval('
		function a()
			i = i + 1
			if i < 1000 then a() end
			i = i + 1
		end
		i = 0
		a()
	')
	print("RESULT 10 (recursive func): ", res, "\n")
	assert((res is int or res is float) and res == 2000, "Result 10 wrong")
	
	# test array
	res = m.eval('
		a = array(3, 2, -100)
		a.sort()
		a[0] = "first"
		a[a.find(3)] = "last"
		a
	')
	print("RESULT 11 (array): ", res, "\n")
	assert((res is Array) and res[0] == "first" and res[1] == 2 and res[2] == "last", "Result 11 wrong")
	
	# test dictionary
	res = m.eval('
		d = dictionary("c": 3, "b": 2, "a": 1).set("d": 4).sort()
		d["e"] = 5
		d.f = 6 // the same as d["f"] = 6
		print(d)
		d.get_or_add("g", 7)
	')
	print("RESULT 12 (dictionary): ", res, "\n")
	assert((res is int or res is float) and res == 7, "Result 12 wrong")
	
	# test iterating
	res = m.eval('
		sum = 0
		while i of 101 do
			sum = sum + i
		end
		print("sum of 1 to 100: " + sum)
		
		// "of" evaluates the right side only once,
		// i.e. the array is not recreated on each iteration
		while value of array(3, 5, 7, 9, 11) do
			print(value + " * 2 = " + (value * 2))
			if value == 7 then stop with value end
		end
	')
	print("RESULT 13 (iterating): ", res, "\n")
	assert((res is int or res is float) and res == 7, "Result 13 wrong")
	
	# test internal variadic functions
	res = m.eval('
		function f(x, args...)
			print(args)
		end
		f() // x is undefined and args is an empty array
		f(1) // x is 1 and args is an empty array
		f(1, 2) // x is 1 and args is [2] (array with one entry)
		f(1, 2, 3) // x is 1 and args is [2, 3]
	')
	print("RESULT 14 (internal variadic func): ", res, "\n")
	assert((res is String) and res == "[2, 3]", "Result 14 wrong")
	
	# test vector types
	res = m.eval('
		v = vector2(2.0)
		v.y = 5.0
		print(v)
		pos = vector3(1, 2, 3)
		pos * 3.0
	')
	print("RESULT 15 (vector types): ", res, "\n")
	assert(res and res is Vector3 and res == Vector3(3.0, 6.0, 9.0), "Result 15 wrong")
	
	# done, results in Output
	print("done.")

	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed(&"ui_cancel"): get_tree().quit()

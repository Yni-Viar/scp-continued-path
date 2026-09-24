# mila.gd

<img src="./mila_logo.png" alt="A mouse with a cloak and wrench" title="mila.gd's mascot Mila" width="320">

A **mi**nimalistic scripting **la**nguage written in GDScript with focus on safe usage (no Godot errors) for embedding. Used in [I Made A Game For You](https://medienzentrale.itch.io/a-game-for-you) and [Mops & Mobs](https://store.steampowered.com/app/2851050/).

---

## Example (GDScript with embedded mila.gd code)

```GDScript
func _mila_some_method(p):
	print(p)

func _ready() -> void:
	var mila := Mila.new(self) # defines this node as target object
	var res = mila.eval('
		// mila.gd code begins here!
 		x = 0 // unitialised variables are "undefined"
		while x < 10 do
			some_method(x) // calls "_mila_some_method()" from the target object
			x = x + 1 // can also be written as "x += 1"
		end')
	print(res)
```

`eval()` returns the value of the last evaluated expression, so in the example this would be the expression `x = x + 1` and the printed result will be "10".

## Limitations

* All variables (apart from function parameters) have global scope
* Probably not the best performance

## Keywords

* `and`, `or`, `not`
* `if`, `then`, `elif`, `else`
* `while`, `of`, `do`
* `function`
* `end` _(to finish blocks of `if`, `while` and `function`)_
* `stop`, `skip`, `exit`, `interrupt`, `with`
* `array`, `dictionary`
* `vector2`, `vector3`, `vector4`, `vector2i`, `vector3i`, `vector4i`

## Usage

### Installation

Only the file `mila.gd` is needed, copy it to your `addons` folder or anywhere else in your Godot project.

### Basics

No semicolons or linebreaks are necessary. Whitespaces are ignored. Comments can start with `//` or `#`.

Use `=` for assignment and `==` for comparison. Compound assignments are supported too (`+=`, `-=`, etc).

Everything is an expression, so you can do things like `x = if y > 10 then 2 elif y > 5 then 1 else 0 end`. Be aware that in some cases the result can be `undefined`, e.g. when the `if` condition is false and there's no `else` clause. Another case is the result of a `while` loop that was stopped via `stop` without `with` modifier.

mila.gd natively supports integers, floats, bools, strings, arrays, dictionaries, vectors, and function calls. 

### Flow control

The only loop construct is the `while`...`end` loop.

Instead of "break" and "continue", write `stop` and `skip` inside a loop.

All flow control keywords (`stop`, `skip`, `exit` and `interrupt`) allow the modifier `with` with an expression, which is then the result of the construct. Example:

```
x = 20
res = while true do
	x -= 1
	if x > 10 then
		skip
	elif x <= 0 then
		stop with "done"
	end
end
print(res) // prints "done"
```

### Functions

Outside functions can be fed to the interpreter by setting a target Godot object whose methods are directly called by mila.gd. The methods have to be prefixed with "\_mila\_", but the prefix can be changed by creating a `String` member variable called `_mila_prefix`. Be aware that setting it to an empty string, potentially dangerous methods like `queue_free()` can be called from mila.gd scripts.

It's also possible to register functions via `register_func()`, no prefix is necessary then.

Internal mila.gd functions allow parameters, and they return the result of the last expression in the body, though `exit` and `exit with <expression>` can be used inside functions for a premature return. (`stop` is allowed too and is the same as `exit` if used directly in the function body. Also `skip` - it returns to the function's beginning, which might be an interesting side effect.) Example:

```
function div(a, b)
	if b == 0 then exit with "ERROR!" end
	a / b
end
print("12/3 = " + div(12, 3)) // prints "12/3 = 4"
print("5/0 = " + div(5, 0)) // prints "5/0 = ERROR!"
```

Both external and internal functions are allowed to be variadic. For internal `function`s, the syntax is `function f(args...)`, i.e. the three dots come after the identifier.

### Arrays and dictionaries

Arrays are always untyped and initialised like this: `a = array(1, 2, 3)`, array access uses square brackets: `foo = a[0]`, `a[1] = "hello"`. Most methods of Godot's arrays are supported, apart from those using Callables, e.g. filter(), and all \_custom() methods. The methods are called via `a.method(<parameters>)`, and most of them return the array again. This way you can use currying, e.g. `a = array(4, 3, 2).append(1).sort()` (`a` will be `[ 1, 2, 3, 4 ]`).

Dictionaries are also supported: `d = dictionary("a": 1, "b": 2, "c": 3)`. The same rules as to arrays apply, and no method regarding types are supported. `set(entry)` returns the dictionary itself instead of true/false like in Godot; `entry` can be a key-value pair (`"health": 5`), or anything else, which then creates a key with undefined value. This also works during `dictionary()` initialisation. Like in GDScript, it's possible to write `d["a"]` as `d.a` (syntactic sugar).

### Iteration

In order to iterate over an array or a dictionary (or a string, or just a number), use `of` in a `while` condition:

```
d = dictionary("name": "Klapauzius", "age": 10000, "weight": 123.4)
while key of d do
	print("Key: " + key + ", Value: " + d[key])
end
```

The right side expression of `of` is evaluated only once. The iterator variable is global, so it keeps its last value after the loop. Iterating over a dictionary via `of` creates a copy of the keys, so - though it's not recommended - it is safe to erase an entry during iteration.

### Interrupting

Using `interrupt` will stop the script execution, but by providing a state Dictionary when calling `run()` or `eval()`, it's possible to continue from the last state. You can also limit the amount of execution steps, and interrupt the script from the outside via `state["interrupt"] = true` (i.e. inside a GDScript function called from mila.gd).

## Credits

mila.gd created by [Friedrich 'ratrogue' Hanisch](https://fholio.de/)

Mila mascot created by [Tom 'voxel' Purnell](https://thomaspurnell.com/)

No LLM was used to create this interpreter.

## History

mila.gd was based on IMP, a [tiny tutorial language](https://jayconrod.com/posts/37/a-simple-interpreter-from-scratch-in-python--part-1-) by Jay Conrod. I needed a small scripting language for our game project, so I ported Conrod's IMP to GDScript, extended it a bit and named it Gimpl (later on Gompl, then slang.gd, and now mila.gd - naming is hard). After a while I wasn't totally satisfied with the outcome, so I took Jay Conrod's advice and ditched the combinators approach and now use recursive descent parsing as described in [Crafting Interpreters](https://craftinginterpreters.com).

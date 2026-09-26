extends MeshInstance3D
class_name GDShaderCompositor
## GDShader Compositor
## Made by Yni, licensed under MIT License.

## All available shader snippets
@export var shaders: Array[GDShaderCompositorResource]
## Leave this empty
@export var used_shaders: PackedInt32Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Constructs full shader from `shaders` variable
## index is which shader snippets will be used, and remove - removes if true
func apply_shader(index: int, remove: bool = false) -> bool:
	#if OS.get_name() == "Web":
		#return false
	if index < 0 || index >= shaders.size() || (used_shaders.has(index) && !remove) || \
	 (!used_shaders.has(index) && remove):
		return false
	if remove:
		used_shaders.erase(index)
		if used_shaders.size() == 0:
			hide()
			return true
	else:
		used_shaders.append(index)
		show()
	var screen_replaced: bool = false
	var fragment_code: String = "vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;"
	var shader: Shader = Shader.new()
	shader.code = """shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;

varying vec4 temp;

"""
	for i in range(shaders.size()):
		if used_shaders.has(i):
			shader.code += "#include \"" + shaders[i].shader_path + "\"\n"
			if shaders[i].replace_screen_texture && !screen_replaced:
				screen_replaced = true
				fragment_code = "vec3 color = " + shaders[i].shader_callable + ".rgb;\n"
	shader.code += "void fragment() {\n"
	shader.code += fragment_code
	shader.code += "\n"
	for i in range(shaders.size()):
		if used_shaders.has(i):
			shader.code += "temp = " + shaders[i].shader_callable + ";\n"
			shader.code += "color = mix(color, temp.rgb, temp.a);\n"
	shader.code += "ALBEDO = color;\n}\n"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.render_priority = -1
	for i in range(shaders.size()):
		if used_shaders.has(i):
			for variables in shaders[i].shader_variables:
				material.set_shader_parameter(variables, shaders[i].shader_variables[variables])
	set_surface_override_material(0, material)
	return true

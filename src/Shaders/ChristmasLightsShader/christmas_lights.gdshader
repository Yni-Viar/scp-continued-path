// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

// Made by Yni
// License: CC0

shader_type spatial;
render_mode blend_mix, diffuse_burley, specular_schlick_ggx;

uniform vec3 emission : source_color;

void fragment() {
	// Emission Operator: Add
	EMISSION = emission * sin(TIME * 4.0);
}

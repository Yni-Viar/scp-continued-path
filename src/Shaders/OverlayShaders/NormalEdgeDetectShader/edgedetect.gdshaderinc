/*
	Made by nuzcraft
	The shader code and all code snippets in this post are under CC0 license
	and can be used freely without the author's permission.

	Edited by Yni for simplifying the shader.
*/

uniform vec4 edgedetect_edge_line_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

const mat2 edgedetect_robert_y = mat2(
	vec2(0.0, 1.0),
	vec2(-1.0, 0.0)
);

const mat2 edgedetect_robert_x = mat2(
	vec2(1.0, 0.0),
	vec2(0.0, -1.0)
);

vec4 edgedetect_simple(sampler2D screen_texture, vec2 screen_uv, vec2 viewport_size) {
	vec4 screen_color = texture(screen_texture, screen_uv);
	vec2 offset = 1.0 / viewport_size;

	vec3 nw = texture(screen_texture, screen_uv + vec2(-offset.x, -offset.y)).rgb;
	vec3 ne = texture(screen_texture, screen_uv + vec2(offset.x, -offset.y)).rgb;
	vec3 sw = texture(screen_texture, screen_uv + vec2(-offset.x, offset.y)).rgb;
	vec3 se = texture(screen_texture, screen_uv + vec2(offset.x, offset.y)).rgb;

	mat2 surrounding_pixels = mat2(
		vec2(length(nw), length(ne)),
		vec2(length(sw), length(se))
	);

	float edge_x = dot(edgedetect_robert_x[0], surrounding_pixels[0]) + dot(edgedetect_robert_x[1], surrounding_pixels[1]);
	float edge_y = dot(edgedetect_robert_y[0], surrounding_pixels[0]) + dot(edgedetect_robert_y[1], surrounding_pixels[1]);

	float edge = sqrt(pow(edge_x, 2.0)+pow(edge_y, 2.0));

	return vec4(edge * edgedetect_edge_line_color.rgb, 1.0);
}

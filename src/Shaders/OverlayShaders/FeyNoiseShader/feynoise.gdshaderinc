//Made by Yni
//Licensed under CC0

float fey_noise_rand(vec2 co){
	return fract(sin(dot(co ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 fey_noise(vec4 fragcoord) {
	float color = fey_noise_rand(floor(fragcoord.xy / 2.0) + TIME);
	return vec4(vec3(clamp(color, 0.0, 0.5)), 0.125);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

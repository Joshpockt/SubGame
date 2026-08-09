shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D screen : hint_screen_texture;
uniform float refraction = 0.0;
varying vec3 pos;

void vertex() {
	pos = VERTEX;
}

void fragment() {
	ALBEDO.rgb = vec3(0.0);
	//ALBEDO.rgb = texture(screen, SCREEN_UV).rgb;
	//ALBEDO.rgb = NODE_POSITION_VIEW;
	float fresnel = pow(-dot(VIEW, NORMAL) + 1.0, 1.0);
	ALBEDO = texture(screen, SCREEN_UV - (NORMAL.xy * refraction)).rgb;
	ALBEDO += fresnel * 0.01;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

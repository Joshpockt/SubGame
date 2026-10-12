shader_type spatial;
render_mode cull_disabled;

//uniform sampler2D noise : source_color;
//uniform float value;

uniform vec3 color : source_color;

void vertex() {
	//VERTEX += sin(TIME + float(VERTEX_ID)) * 0.1;
}

void fragment() {
	ALPHA = 0.5;
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

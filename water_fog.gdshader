shader_type spatial;
render_mode unshaded, fog_disabled, blend_premul_alpha;
stencil_mode read, 1, compare_equal;

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	ALBEDO = vec3(1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

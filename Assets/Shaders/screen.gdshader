shader_type spatial;
//render_mode unshaded;

uniform sampler2D screen_texture : filter_nearest, hint_default_black;
uniform float scanlines = 1.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	vec4 tex = texture(screen_texture, UV);
	ivec2 tex_size = textureSize(screen_texture, 0);
	float offset = 1.0 / float(tex_size.x);
	vec4 left = texture(screen_texture, UV + vec2(-offset, 0)) * vec4(0.25, 1.0, 0.25, 1.0);
	vec4 right = texture(screen_texture, UV + vec2(offset, 0)) * vec4(1.0, 0.25, 1.0, 1.0);
	vec4 blur = (tex + ((left + right) * 0.2)) / 1.0;
	ALBEDO = (blur.rgb * 0.8) + (blur.rgb * (abs(sin(UV.y * PI * scanlines)))) * 0.5;
	//ALBEDO = blur.rgb;
	//IRRADIANCE = tex * 5.0;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type spatial;

uniform sampler2D tex : filter_nearest;

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
}

void light() {
	vec3 light_color = LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * light_color;
}
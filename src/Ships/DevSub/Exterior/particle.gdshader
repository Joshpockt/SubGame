shader_type spatial;
render_mode cull_disabled, world_vertex_coords, vertex_lighting;

//uniform float max_distance = 100.0;

varying vec4 color;
varying float distance_to_camera;

void vertex() {
	color = COLOR;
	distance_to_camera = distance(VERTEX, CAMERA_POSITION_WORLD);
	//POINT_SIZE = ((distance_to_camera / max_distance) * -1.0 + 1.0) * 3.5;
}

void fragment() {
	BACKLIGHT = vec3(1.0);
	ALBEDO = color.rgb;
	//EMISSION = color.rgb * 50.0;
	ALPHA = color.a;
}

void light() {
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
	ALPHA *= length(DIFFUSE_LIGHT) / 3.0;
}

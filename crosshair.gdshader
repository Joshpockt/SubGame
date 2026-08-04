shader_type canvas_item;

uniform bool can_interact = false;
uniform sampler2D screen_texture : hint_screen_texture;
uniform float circleSize=.2;
uniform float hollowSize=.2;
uniform float progress : hint_range(0.0, 1.0) = .9;

void fragment() {
	vec2 center = vec2(0.5);
	vec2 p = UV - center;
	float angle = atan(p.y, p.x);
	angle = (angle + PI) / (PI * 2.0);
	angle = mod(angle + 0.75, 1.0);
	float feather = 0.05;
	float mask = 1.0 - smoothstep(progress, progress + feather, angle);
	COLOR.rgb = texture(screen_texture,SCREEN_UV).rgb * -1.0 + 1.0;
	COLOR.a = 0.0;
	COLOR.a = smoothstep(circleSize, circleSize-.025, distance(vec2(0.5), UV));
	COLOR.a -= smoothstep(hollowSize, hollowSize-.025, distance(vec2(0.5), UV));
	COLOR.a*=mask;
}

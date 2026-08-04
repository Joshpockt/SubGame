shader_type canvas_item;

uniform bool can_interact = false;
uniform sampler2D screen_texture : hint_screen_texture;
uniform float circleSize=.2;
uniform float hollowSize=.2;

void fragment() {
	COLOR.rgb = texture(screen_texture,SCREEN_UV).rgb * -1.0 + 1.0;
	COLOR.a = 0.0;
	COLOR.a = smoothstep(circleSize, circleSize-.025, distance(vec2(0.5), UV));
	COLOR.a -= smoothstep(hollowSize, hollowSize-.025, distance(vec2(0.5), UV));
}

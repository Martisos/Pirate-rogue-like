shader_type canvas_item;

uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float frequency : hint_range(0.0, 25.0) = 0.35;
uniform float highlight_speed : hint_range(0.0, 25.0) = 6.0;
uniform float highlight_width : hint_range(0.0, 50.0) = 15.0;

void fragment( )
{
	vec4 input_color = texture(TEXTURE, UV);
	float width = 0.001 * frequency * highlight_width / 2.0;
	float value = floor(sin(frequency * ((UV.x - UV.y) + TIME * highlight_speed)) + width);
	float highlight = value > 0.5? 1.0: 0.0;
	vec3 new_color = input_color.rgb * (1.0 - highlight) + highlight_color.rgb * highlight;
	COLOR = vec4(new_color, input_color.a);
}
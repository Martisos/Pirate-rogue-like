shader_type canvas_item;

uniform float time_speed = 0.5;
uniform float wave_amplitude = 0.01;

uniform int wave_frequency1 = 3;
uniform int wave_frequency2 = 1;

uniform vec4 water_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2  uv = UV;
	
	uv.x += sin(TIME * time_speed + (uv.y * TAU * float(wave_frequency1))) * wave_amplitude;
	uv.y += cos(TIME * time_speed + (uv.x * TAU * float(wave_frequency1))) * wave_amplitude;
	
	uv.x += sin(TIME * (time_speed * 1.5) - (uv.y * TAU * float(wave_frequency2))) * wave_amplitude;
	uv.y += cos(TIME * (time_speed * 1.2) - (uv.x * TAU * float(wave_frequency2))) * wave_amplitude;
	
	vec4 tex_color = texture(TEXTURE, uv);
	
	COLOR = tex_color * water_tint;
}

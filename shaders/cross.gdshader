shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false

// --- NOWE PARAMETRY DO PULSOWANIA ---
uniform bool enable_pulsing = true;                    // Czy ma migać?
uniform float pulse_speed : hint_range(0.0, 20.0) = 5.0; // Jak szybko miga
uniform float min_alpha : hint_range(0.0, 1.0) = 0.3;    // Jak mocno przygasa (minimalna przezroczystość)

void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec2 uv = UV;
	
	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));
		
		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
		
		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv);
		}
	} else {
		COLOR = texture(TEXTURE, uv);
	}
	
	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		
		// --- OBLICZANIE PULSOWANIA ---
		vec4 final_color = color;
		if (enable_pulsing) {
			// Fala sinus o wartościach od 0.0 do 1.0
			float pulse = (sin(TIME * pulse_speed) + 1.0) / 2.0;
			// Skalujemy ją do naszego zakresu (np. od min_alpha do 1.0)
			float current_alpha = mix(min_alpha, 1.0, pulse);
			final_color.a *= current_alpha;
		}
		// -----------------------------
		
		COLOR.rgb = inside ? mix(COLOR.rgb, final_color.rgb, final_color.a) : final_color.rgb;
		COLOR.a += (1.0 - COLOR.a) * final_color.a;
	}
}
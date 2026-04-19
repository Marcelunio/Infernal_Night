//Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float scanline_strength: hint_range(0.0, 1.0) = 0.03;
uniform float vignette_strength: hint_range(0.0, 1.0) = 0.15;
uniform float snow_strength: hint_range(0.0, 1.0) = 0.04;
uniform float time = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = texture(screen_texture, uv);
	
	// scanlines
	float scanline = sin(uv.y * 800.0 + time * 0.5) * scanline_strength;
	color.rgb -= scanline;
	
	vec2 snow_uv = uv * 500.0;
	snow_uv.y += time * 30.0;  // przesuwa w dół
	float snow = fract(sin(dot(snow_uv, vec2(12.9898, 78.233))) * 43758.5453);
	snow = step(0.95, snow);
	color.rgb += snow * snow_strength;
	
	// vignette
	vec2 vig = uv * (1.0 - uv);
	float vignette = pow(vig.x * vig.y * 15.0, vignette_strength);
	color.rgb *= vignette;
	
	COLOR = color;
}
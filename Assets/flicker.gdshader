shader_type canvas_item;

uniform float max_flicker;
uniform float flicker_duration;

void fragment() {
	COLOR.a*=step(abs(sin(min(TIME*TIME/flicker_duration,TIME*max_flicker))),0.5);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

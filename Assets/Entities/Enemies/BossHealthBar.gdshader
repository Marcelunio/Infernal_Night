shader_type canvas_item;

uniform float fill: hint_range(0.0, 1.0)=1.;
uniform sampler2D lost;
void fragment() {
	vec4 broken_color=texture(lost,UV);
	COLOR=(1.-step(fill,UV.x))*broken_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

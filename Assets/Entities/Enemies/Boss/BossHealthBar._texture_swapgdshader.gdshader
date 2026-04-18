shader_type canvas_item;

uniform float fill_in: hint_range(0.0, 1.0)=1.;
uniform sampler2D broken;
void fragment() {
	float fill=(fill_in-0.02)*1.03;
	vec4 broken_color= texture(broken,UV);
	COLOR=((1.-step(fill,UV.x))*COLOR+(step(fill,UV.x))*broken_color)-(1.-((step(fill+0.01,UV.x))+(1.-step(fill-0.01,UV.x))))*vec4(0,0,0,1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

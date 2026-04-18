shader_type canvas_item;

void fragment() {
	vec4 color= texture(TEXTURE,UV);
	vec2 size = TEXTURE_PIXEL_SIZE*2.;
	float outline=color.a;
	for(float y=-1.;y<=1.;y++)
	{
		for(float x=-1.;x<=1.;x++)
		{
			vec2 offset=vec2(x,y)*size;
			outline+=texture(TEXTURE,UV+offset).a;
		}
	}
	outline=min(outline,1.);
	COLOR= mix(color,vec4(1.,1.,1.,1.),outline-color.a);
}
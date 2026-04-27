shader_type canvas_item;
uniform vec4 uni_color: source_color = vec4(1,1,1,1);
uniform int width=2;

void fragment() {
	if(width!=0)
	{
	vec4 color= texture(TEXTURE,UV);
	vec2 size = TEXTURE_PIXEL_SIZE*float(width);
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
	COLOR= mix(color,vec4(1.,1.,1.,1.),(outline-color.a)*uni_color);
	}
}
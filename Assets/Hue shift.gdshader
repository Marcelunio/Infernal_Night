shader_type canvas_item;

uniform vec3 d_HSV;


vec3 RGB_HSV(vec3 RGB)
{
	float Cmin=min(RGB.r,min(RGB.b,RGB.g));
	float V=max(RGB.r,max(RGB.b,RGB.g));
	float delta= V - Cmin;
	float H=    delta==0. ? 0.:
				RGB.r == V ? (mod((RGB.g-RGB.b),6.)/delta):
				RGB.g== V ?((2.+(RGB.b-RGB.r))/delta ): 
				((4.+(RGB.r-RGB.g))/delta );
	float S= delta/V;
	return vec3(H,S,V);
}
vec3 HSV_RGB(vec3 HSV) {
	vec3 tRGB=vec3(0,0,0);
	float C= HSV.z*HSV.y;
	float m = HSV.z-C;
	float X= C* (1.-abs(mod(HSV.x,2.)-1.));
	vec2 parity= (int(HSV.x)%2==0 ) ? vec2(C,X) : vec2(X,C);
	int position=int(floor(HSV.x/2.)) %3;
	if(position ==2 )
	{
		tRGB.zx =parity;
		return tRGB+m;
	}
	tRGB = (position	==0) ? vec3(parity,0) : vec3(0,parity);
	return tRGB+m;
}
void fragment() {
 	vec3 HSV= RGB_HSV(COLOR.rgb);
	HSV.x=abs(mod(HSV.x+d_HSV.x/60.,6.));
	HSV.y=clamp(HSV.y*(1.+d_HSV.y/100.),0,1.);
	HSV.z=clamp(HSV.z*(1.+d_HSV.z/100.),0.,1.);
	COLOR.rgb= HSV_RGB(HSV);
	
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
